const fs = require('fs');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();

const dbPath = path.join(__dirname, 'books.db');

// If books.db already exists, remove it to start fresh
if (fs.existsSync(dbPath)) {
  fs.unlinkSync(dbPath);
}

const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Failed to create database:', err.message);
    process.exit(1);
  }
  console.log('Connected to SQLite database: books.db');
});

const sqlScript = fs.readFileSync(path.join(__dirname, 'setup.sql'), 'utf-8');

db.exec(sqlScript, (err) => {
  if (err) {
    console.error('Error initializing database:', err.message);
    process.exit(1);
  }
  console.log('Database initialized successfully with 10 book rows.');

  // Verify rows
  db.all('SELECT * FROM book', [], (err, rows) => {
    if (err) {
      console.error('Error querying table:', err.message);
    } else {
      console.log(`Verified: ${rows.length} rows inserted into book table.`);
      console.table(rows);
    }
    db.close();
  });
});
