# Lab 3: REST API, query parameters, validation, debugging

**Name:** Kollampally Sai Nihal 
**Registration number:** 252U1R6104
**Section:** AIML-2B

**Live link:** https://backend-development-lab-3-rz2x.onrender.com/

## Objective
Turn the Lab 2 book routes into a REST API with search, sorting, price filtering, pagination, validation, correct status codes and debugging practice.

## Requirements
- Node.js and npm
- SQLite database
- Postman

## Install and run
```powershell
npm install
npm run dev
```
For normal start:
```powershell
npm start
```
The server runs on `http://localhost:3000`.

## Environment variables
- `PORT` — server port. Local default: 3000.
- `DB_PATH` — optional full path to the SQLite database file. Local default: `books.db` in this folder.

No real secrets are used in this project. `.env` is not committed.

## Database
`books.db` contains the `book` table (`id`, `title`, `author`, `price`, `pages`). The SQL that creates the table and inserts 61 sample books is in `database/books.sql`.

## Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/` | API health check |
| GET | `/books` | List books with search, sort, price filters and pagination |
| GET | `/books/:bookId` | Get one book |
| POST | `/books` | Create a book |
| PUT | `/books/:bookId` | Update a book |
| DELETE | `/books/:bookId` | Delete a book |

### GET /books query parameters
- `search_q` — partial title search; no search filter if omitted.
- `order_by` — one of `id`, `title`, `author`, `price`, `pages`; default `id`.
- `order` — `ASC` or `DESC`; default `ASC`.
- `limit` — integer 1–100; default `100`.
- `offset` — non-negative integer; default `0`.
- `min_price` — optional non-negative number.
- `max_price` — optional non-negative number.

Example:
`/books?search_q=atomic&order_by=price&order=DESC&limit=5&offset=0&min_price=100&max_price=500`

### POST and PUT JSON body
```json
{
  "title": "Test Book",
  "author": "Test Author",
  "price": 250,
  "pages": 150
}
```

### Status codes used
| Status | When |
|---|---|
| 200 | Successful GET, PUT or DELETE |
| 201 | Book created with POST |
| 400 | Invalid query parameter, invalid id, or invalid request body |
| 404 | Book not found, or unknown route |
| 500 | Unexpected database error |

## Tests performed (Postman)

| # | Request | Result | Screenshot |
|---|---|---|---|
| 1 | GET `/books` | 200, all books | `01-get-all-books.png` |
| 2 | GET `/books?search_q=python` | 200, titles containing "python" | `02-search-by-title.png` |
| 3 | GET `/books?order_by=price&order=DESC` | 200, highest price first | `03-sort-price-desc.png` |
| 4 | GET `/books?min_price=300&max_price=700` | 200, prices from 300 to 700 | `04-price-range-filter.png` |
| 5 | GET `/books?limit=2&offset=0` | 200, first 2 books | `05-pagination-limit-offset.png` |
| 6 | POST `/books` with valid JSON | 201, new book with id 63 | `06-post-success-201.png` |
| 7 | GET `/books/99999` | 404, Book not found | `07-get-book-not-found-404.png` |
| 8 | PUT `/books/1` | 404, Book not found | `08-put-book-not-found-404.png` |
| 9 | DELETE `/books/2` | 200, Book deleted successfully | `09-delete-success-200.png` |
| 10 | DELETE `/books/99999` | 404, Book not found | `10-delete-book-not-found-404.png` |

## Screenshots

### 1. GET /books - all books (200)
![GET all books](screenshots/01-get-all-books.png)

### 2. Search by title - search_q=python (200)
![Search by title](screenshots/02-search-by-title.png)

### 3. Sort by price descending (200)
![Sort price descending](screenshots/03-sort-price-desc.png)

### 4. Price range filter - min_price=300, max_price=700 (200)
![Price range filter](screenshots/04-price-range-filter.png)

### 5. Pagination - limit=2, offset=0 (200)
![Pagination](screenshots/05-pagination-limit-offset.png)

### 6. POST /books - create a book (201)
![POST success](screenshots/06-post-success-201.png)

### 7. GET /books/99999 - book not found (404)
![GET book not found](screenshots/07-get-book-not-found-404.png)

### 8. PUT /books/1 - book not found (404)
![PUT book not found](screenshots/08-put-book-not-found-404.png)

### 9. DELETE /books/2 - delete a book (200)
![DELETE success](screenshots/09-delete-success-200.png)

### 10. DELETE /books/99999 - book not found (404)
![DELETE book not found](screenshots/10-delete-book-not-found-404.png)

## Notes
- All values from the user go into SQL through `?` placeholders. Search text, price limits, `limit` and `offset` are never joined into the query string.
- A column name cannot be a `?` placeholder, so `order_by` is checked against a fixed list of allowed columns (`id`, `title`, `author`, `price`, `pages`) before it is used in `ORDER BY`. `order` must be `ASC` or `DESC`.
- `limit` must be an integer from 1 to 100 and `offset` must be a non-negative integer, otherwise the API returns 400.
- `bookId` must be a positive integer, otherwise the API returns 400. A valid id that does not exist returns 404.
- POST and PUT check that `title` and `author` are non-empty text, `price` is a non-negative number and `pages` is a positive integer.
- Every route returns JSON with the right status code, and database errors are caught and returned as 500.
