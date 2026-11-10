const express = require('express')
const path = require('path')
const sqlite3 = require('sqlite3')
const { open } = require('sqlite')

const app = express()
const PORT = process.env.PORT || 3000
const dbPath = process.env.DB_PATH || path.join(__dirname, 'books.db')

app.use(express.json())

let db = null

app.get('/', (req, res) => {
  res.send('Server is running successfully!')
})

app.get('/books/', async (req, res) => {
  try {
    const {
      search_q,
      order_by = 'id',
      order = 'ASC',
      limit = '100',
      offset = '0',
      min_price,
      max_price,
    } = req.query

    const allowedColumns = ['id', 'title', 'author', 'price', 'pages']
    const sortOrder = String(order).toUpperCase()

    if (!allowedColumns.includes(order_by)) {
      return res.status(400).json({ error: 'Invalid order_by value' })
    }
    if (!['ASC', 'DESC'].includes(sortOrder)) {
      return res.status(400).json({ error: 'order must be ASC or DESC' })
    }

    const pageLimit = Number(limit)
    const pageOffset = Number(offset)
    if (!Number.isInteger(pageLimit) || pageLimit < 1 || pageLimit > 100) {
      return res.status(400).json({ error: 'limit must be an integer between 1 and 100' })
    }
    if (!Number.isInteger(pageOffset) || pageOffset < 0) {
      return res.status(400).json({ error: 'offset must be a non-negative integer' })
    }

    const conditions = []
    const params = []

    if (search_q !== undefined) {
      conditions.push('title LIKE ?')
      params.push(`%${search_q}%`)
    }
    if (min_price !== undefined) {
      const minPrice = Number(min_price)
      if (!Number.isFinite(minPrice) || minPrice < 0) {
        return res.status(400).json({ error: 'min_price must be a non-negative number' })
      }
      conditions.push('price >= ?')
      params.push(minPrice)
    }
    if (max_price !== undefined) {
      const maxPrice = Number(max_price)
      if (!Number.isFinite(maxPrice) || maxPrice < 0) {
        return res.status(400).json({ error: 'max_price must be a non-negative number' })
      }
      conditions.push('price <= ?')
      params.push(maxPrice)
    }
    if (min_price !== undefined && max_price !== undefined &&
        Number(min_price) > Number(max_price)) {
      return res.status(400).json({ error: 'min_price cannot be greater than max_price' })
    }

    let sql = 'SELECT * FROM book'
    if (conditions.length) sql += ` WHERE ${conditions.join(' AND ')}`
    sql += ` ORDER BY ${order_by} ${sortOrder} LIMIT ? OFFSET ?`
    params.push(pageLimit, pageOffset)

    const books = await db.all(sql, params)
    return res.status(200).json(books)
  } catch (error) {
    return res.status(500).json({ error: 'Unable to get books' })
  }
})

app.get('/books/:bookId/', async (req, res) => {
  try {
    const bookId = Number(req.params.bookId)
    if (!Number.isInteger(bookId) || bookId < 1) {
      return res.status(400).json({ error: 'bookId must be a positive integer' })
    }
    const book = await db.get('SELECT * FROM book WHERE id = ?', [bookId])
    if (!book) return res.status(404).json({ error: 'Book not found' })
    return res.status(200).json(book)
  } catch (error) {
    return res.status(500).json({ error: 'Unable to get book' })
  }
})

app.post('/books/', async (req, res) => {
  try {
    const { title, author, price, pages } = req.body
    if (typeof title !== 'string' || !title.trim() ||
        typeof author !== 'string' || !author.trim() ||
        price === undefined || !Number.isFinite(Number(price)) || Number(price) < 0 ||
        pages === undefined || !Number.isInteger(Number(pages)) || Number(pages) < 1) {
      return res.status(400).json({
        error: 'title, author, a non-negative price, and positive integer pages are required'
      })
    }

    const result = await db.run(
      'INSERT INTO book (title, author, price, pages) VALUES (?, ?, ?, ?)',
      [title.trim(), author.trim(), Number(price), Number(pages)]
    )
    const newBook = await db.get('SELECT * FROM book WHERE id = ?', [result.lastID])
    return res.status(201).json(newBook)
  } catch (error) {
    return res.status(500).json({ error: 'Unable to create book' })
  }
})

app.put('/books/:bookId/', async (req, res) => {
  try {
    const bookId = Number(req.params.bookId)
    const { title, author, price, pages } = req.body
    if (!Number.isInteger(bookId) || bookId < 1) {
      return res.status(400).json({ error: 'bookId must be a positive integer' })
    }
    if (typeof title !== 'string' || !title.trim() ||
        typeof author !== 'string' || !author.trim() ||
        price === undefined || !Number.isFinite(Number(price)) || Number(price) < 0 ||
        pages === undefined || !Number.isInteger(Number(pages)) || Number(pages) < 1) {
      return res.status(400).json({
        error: 'title, author, a non-negative price, and positive integer pages are required'
      })
    }

    const existingBook = await db.get('SELECT id FROM book WHERE id = ?', [bookId])
    if (!existingBook) return res.status(404).json({ error: 'Book not found' })

    await db.run(
      'UPDATE book SET title = ?, author = ?, price = ?, pages = ? WHERE id = ?',
      [title.trim(), author.trim(), Number(price), Number(pages), bookId]
    )
    const updatedBook = await db.get('SELECT * FROM book WHERE id = ?', [bookId])
    return res.status(200).json(updatedBook)
  } catch (error) {
    return res.status(500).json({ error: 'Unable to update book' })
  }
})

app.delete('/books/:bookId/', async (req, res) => {
  try {
    const bookId = Number(req.params.bookId)
    if (!Number.isInteger(bookId) || bookId < 1) {
      return res.status(400).json({ error: 'bookId must be a positive integer' })
    }
    const existingBook = await db.get('SELECT id FROM book WHERE id = ?', [bookId])
    if (!existingBook) return res.status(404).json({ error: 'Book not found' })
    await db.run('DELETE FROM book WHERE id = ?', [bookId])
    return res.status(200).json({ message: 'Book deleted successfully' })
  } catch (error) {
    return res.status(500).json({ error: 'Unable to delete book' })
  }
})

app.use((req, res) => {
  res.status(404).json({ message: 'Route not found' })
})

const initializeDBAndServer = async () => {
  try {
    db = await open({ filename: dbPath, driver: sqlite3.Database })
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`Server running at http://localhost:${PORT}`)
    })
  } catch (error) {
    console.error('Database connection failed:', error.message)
    process.exit(1)
  }
}

initializeDBAndServer()
