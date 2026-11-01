/**
 * Lab 2: SQLite database and CRUD routes
 * Backend Development Fundamentals · Year II Term II · Aurora
 * Faculty: Joel Prashanth D
 * Student Name: Kollampally Sai Nihal
 * Registration Number: 252U1R6104
 * Section: AIML-IB
 */

const express = require('express');
const path = require('path');
const { open } = require('sqlite');
const sqlite3 = require('sqlite3');
require('dotenv').config();

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;
const dbPath = path.join(__dirname, 'books.db');

let db = null;

// Middleware: Request logger to log method, URL, status code, and latency
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[LOG] ${req.method} ${req.originalUrl} -> Status: ${res.statusCode} (${duration}ms)`);
  });
  next();
});

// Task 3: initializeDBAndServer() async function
const initializeDBAndServer = async () => {
  try {
    db = await open({
      filename: dbPath,
      driver: sqlite3.Database,
    });

    // Ensure book table exists
    await db.exec(`
      CREATE TABLE IF NOT EXISTS book (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        price INTEGER NOT NULL,
        pages INTEGER NOT NULL
      );
    `);

    app.listen(PORT, () => {
      console.log(`Server running at http://localhost:${PORT}/`);
      console.log(`Connected to database: ${dbPath}`);
      console.log('Available Endpoints:');
      console.log(`  - GET    http://localhost:${PORT}/books/`);
      console.log(`  - GET    http://localhost:${PORT}/books/:bookId/`);
      console.log(`  - POST   http://localhost:${PORT}/books/`);
      console.log(`  - PUT    http://localhost:${PORT}/books/:bookId/`);
      console.log(`  - DELETE http://localhost:${PORT}/books/:bookId/`);
    });
  } catch (error) {
    console.error(`DB Connection Error: ${error.message}`);
    process.exit(1);
  }
};

initializeDBAndServer();

// Root route: API Information & Overview
app.get('/', (req, res) => {
  res.status(200).json({
    lab: 'Lab 2: SQLite database and CRUD routes',
    course: 'Backend Development Fundamentals · Year II Term II',
    student: {
      name: 'Kollampally Sai Nihal',
      registrationNumber: '252U1R6104',
      section: 'AIML-IB',
    },
    endpoints: {
      getAllBooks: 'GET /books/',
      getSingleBook: 'GET /books/:bookId/',
      addBook: 'POST /books/',
      updateBook: 'PUT /books/:bookId/',
      deleteBook: 'DELETE /books/:bookId/',
    },
  });
});

// Task 4 - Route 1: GET /books/ (Fetch all books)
app.get('/books/', async (request, response) => {
  try {
    const getBooksQuery = `
      SELECT
        id,
        title,
        author,
        price,
        pages
      FROM
        book
      ORDER BY
        id ASC;
    `;
    const booksArray = await db.all(getBooksQuery);
    response.status(200).json(booksArray);
  } catch (error) {
    response.status(500).json({ error: error.message });
  }
});

// Task 4 - Route 2: GET /books/:bookId/ (Fetch a single book by ID with ? placeholder)
app.get('/books/:bookId/', async (request, response) => {
  try {
    const { bookId } = request.params;
    const getBookQuery = `
      SELECT
        id,
        title,
        author,
        price,
        pages
      FROM
        book
      WHERE
        id = ?;
    `;
    const book = await db.get(getBookQuery, [bookId]);
    if (book === undefined) {
      return response.status(404).json({ error: 'Book not found' });
    }
    response.status(200).json(book);
  } catch (error) {
    response.status(500).json({ error: error.message });
  }
});

// Task 4 - Route 3: POST /books/ (Add a new book with ? placeholders)
app.post('/books/', async (request, response) => {
  try {
    const { title, author, price, pages } = request.body;
    if (!title || !author || price === undefined || pages === undefined) {
      return response.status(400).json({
        error: 'Missing required fields: title, author, price, pages',
      });
    }

    const addBookQuery = `
      INSERT INTO
        book (title, author, price, pages)
      VALUES
        (?, ?, ?, ?);
    `;
    const dbResponse = await db.run(addBookQuery, [title, author, price, pages]);
    const bookId = dbResponse.lastID;
    response.status(201).json({
      message: 'Book Added Successfully',
      bookId: bookId,
    });
  } catch (error) {
    response.status(500).json({ error: error.message });
  }
});

// Task 4 - Route 4: PUT /books/:bookId/ (Update an existing book by ID with ? placeholders)
app.put('/books/:bookId/', async (request, response) => {
  try {
    const { bookId } = request.params;
    const { title, author, price, pages } = request.body;

    if (!title || !author || price === undefined || pages === undefined) {
      return response.status(400).json({
        error: 'Missing required fields: title, author, price, pages',
      });
    }

    // Verify if book exists
    const checkBookQuery = `
      SELECT
        id
      FROM
        book
      WHERE
        id = ?;
    `;
    const existingBook = await db.get(checkBookQuery, [bookId]);
    if (existingBook === undefined) {
      return response.status(404).json({ error: 'Book not found' });
    }

    const updateBookQuery = `
      UPDATE
        book
      SET
        title = ?,
        author = ?,
        price = ?,
        pages = ?
      WHERE
        id = ?;
    `;
    await db.run(updateBookQuery, [title, author, price, pages, bookId]);
    response.status(200).json({
      message: 'Book Updated Successfully',
    });
  } catch (error) {
    response.status(500).json({ error: error.message });
  }
});

// Task 4 - Route 5: DELETE /books/:bookId/ (Remove a book by ID with ? placeholder)
app.delete('/books/:bookId/', async (request, response) => {
  try {
    const { bookId } = request.params;

    // Verify if book exists
    const checkBookQuery = `
      SELECT
        id
      FROM
        book
      WHERE
        id = ?;
    `;
    const existingBook = await db.get(checkBookQuery, [bookId]);
    if (existingBook === undefined) {
      return response.status(404).json({ error: 'Book not found' });
    }

    const deleteBookQuery = `
      DELETE FROM
        book
      WHERE
        id = ?;
    `;
    await db.run(deleteBookQuery, [bookId]);
    response.status(200).json({
      message: 'Book Deleted Successfully',
    });
  } catch (error) {
    response.status(500).json({ error: error.message });
  }
});

// 404 Handler for undefined routes
app.use((req, res) => {
  res.status(404).json({
    error: '404 Not Found',
    message: `Cannot ${req.method} ${req.originalUrl}`,
    statusCode: 404,
  });
});

module.exports = app;
