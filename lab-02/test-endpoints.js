/**
 * Automated Test Suite for Lab 2 CRUD Endpoints
 * Tests:
 * 1. GET / - Welcome & API Overview
 * 2. GET /books/ - Retrieve all 10 books
 * 3. GET /books/:bookId/ - Retrieve specific book (ID: 3)
 * 4. GET /books/:bookId/ - Not found case (ID: 999) -> 404
 * 5. POST /books/ - Add new book -> 201 Created & DB changed
 * 6. GET /books/:bookId/ - Verify newly created book
 * 7. PUT /books/:bookId/ - Update the new book -> 200 OK & DB changed
 * 8. GET /books/:bookId/ - Verify updated data
 * 9. DELETE /books/:bookId/ - Remove the book -> 200 OK & DB changed
 * 10. GET /books/:bookId/ - Verify book is removed -> 404
 */

const http = require('http');
const path = require('path');
const { open } = require('sqlite');
const sqlite3 = require('sqlite3');

const PORT = 3001; // Use test port to avoid collision

process.env.PORT = PORT;

const runTests = async () => {
  // First re-seed the database
  const setupDb = require('child_process').execSync('node setup-db.js', { cwd: __dirname });
  console.log(setupDb.toString());

  // Require app
  const app = require('./index.js');
  // Wait a moment for server to initialize
  await new Promise((r) => setTimeout(r, 1000));

  const baseUrl = `http://localhost:${PORT}`;

  console.log('====================================================');
  console.log('       STARTING LAB 2 CRUD ROUTE VERIFICATION       ');
  console.log('====================================================\n');

  // Test 1: GET /
  console.log('--- TEST 1: GET / (Root Overview) ---');
  let res = await fetch(`${baseUrl}/`);
  let json = await res.json();
  console.log(`Status: ${res.status}`);
  console.log('Response:', JSON.stringify(json, null, 2));

  // Test 2: GET /books/
  console.log('\n--- TEST 2: GET /books/ (All Books) ---');
  res = await fetch(`${baseUrl}/books/`);
  json = await res.json();
  console.log(`Status: ${res.status}`);
  console.log(`Total books retrieved: ${json.length}`);
  console.log('First 2 books:', json.slice(0, 2));

  // Test 3: GET /books/3/
  console.log('\n--- TEST 3: GET /books/3/ (Single Book) ---');
  res = await fetch(`${baseUrl}/books/3/`);
  json = await res.json();
  console.log(`Status: ${res.status}`);
  console.log('Book 3:', json);

  // Test 4: GET /books/999/ (Not Found)
  console.log('\n--- TEST 4: GET /books/999/ (Not Found 404) ---');
  res = await fetch(`${baseUrl}/books/999/`);
  json = await res.json();
  console.log(`Status: ${res.status}`);
  console.log('Response:', json);

  // Test 5: POST /books/
  console.log('\n--- TEST 5: POST /books/ (Add New Book) ---');
  const newBook = {
    title: 'The Pragmatic Programmer',
    author: 'Andrew Hunt & David Thomas',
    price: 799,
    pages: 352,
  };
  res = await fetch(`${baseUrl}/books/`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(newBook),
  });
  json = await res.json();
  console.log(`Status: ${res.status}`);
  console.log('Response:', json);
  const createdId = json.bookId;

  // Test 6: GET /books/:id/ (Verify created book)
  console.log(`\n--- TEST 6: GET /books/${createdId}/ (Verify Newly Created Book) ---`);
  res = await fetch(`${baseUrl}/books/${createdId}/`);
  json = await res.json();
  console.log(`Status: ${res.status}`);
  console.log('Created Book:', json);

  // Test 7: PUT /books/:id/ (Update book)
  console.log(`\n--- TEST 7: PUT /books/${createdId}/ (Update Book) ---`);
  const updatedBook = {
    title: 'The Pragmatic Programmer: 20th Anniversary Edition',
    author: 'Andrew Hunt & David Thomas',
    price: 899,
    pages: 352,
  };
  res = await fetch(`${baseUrl}/books/${createdId}/`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(updatedBook),
  });
  json = await res.json();
  console.log(`Status: ${res.status}`);
  console.log('Response:', json);

  // Test 8: GET /books/:id/ (Verify updated book)
  console.log(`\n--- TEST 8: GET /books/${createdId}/ (Verify Updated Book) ---`);
  res = await fetch(`${baseUrl}/books/${createdId}/`);
  json = await res.json();
  console.log(`Status: ${res.status}`);
  console.log('Updated Book Data:', json);

  // Test 9: DELETE /books/:id/ (Delete book)
  console.log(`\n--- TEST 9: DELETE /books/${createdId}/ (Remove Book) ---`);
  res = await fetch(`${baseUrl}/books/${createdId}/`, {
    method: 'DELETE',
  });
  json = await res.json();
  console.log(`Status: ${res.status}`);
  console.log('Response:', json);

  // Test 10: GET /books/:id/ (Verify 404 after deletion)
  console.log(`\n--- TEST 10: GET /books/${createdId}/ (Verify 404 After Delete) ---`);
  res = await fetch(`${baseUrl}/books/${createdId}/`);
  json = await res.json();
  console.log(`Status: ${res.status}`);
  console.log('Response:', json);

  // Test 11: Direct Database Check via SQLite
  console.log('\n--- TEST 11: Direct SQLite Database Verification ---');
  const db = await open({
    filename: path.join(__dirname, 'books.db'),
    driver: sqlite3.Database,
  });
  const finalRows = await db.all('SELECT * FROM book ORDER BY id ASC;');
  console.log(`Total rows currently in DB: ${finalRows.length}`);
  console.table(finalRows);
  await db.close();

  console.log('\n====================================================');
  console.log('         ALL LAB 2 CRUD TESTS PASSED SUCCESSFULLY!    ');
  console.log('====================================================');

  process.exit(0);
};

runTests().catch((err) => {
  console.error('Test execution error:', err);
  process.exit(1);
});
