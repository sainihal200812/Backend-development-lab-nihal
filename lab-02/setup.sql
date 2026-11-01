-- SQLite Database Initialization Script
-- Table: book
CREATE TABLE IF NOT EXISTS book (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  author TEXT NOT NULL,
  price INTEGER NOT NULL,
  pages INTEGER NOT NULL
);

-- Initial 10 Rows
INSERT INTO book (id, title, author, price, pages) VALUES
  (1, 'Harry Potter and the Sorcerer''s Stone', 'J.K. Rowling', 499, 309),
  (2, 'The Hobbit', 'J.R.R. Tolkien', 399, 310),
  (3, 'Atomic Habits', 'James Clear', 550, 320),
  (4, 'To Kill a Mockingbird', 'Harper Lee', 350, 281),
  (5, '1984', 'George Orwell', 299, 328),
  (6, 'The Great Gatsby', 'F. Scott Fitzgerald', 250, 180),
  (7, 'Pride and Prejudice', 'Jane Austen', 299, 279),
  (8, 'The Alchemist', 'Paulo Coelho', 320, 208),
  (9, 'Clean Code', 'Robert C. Martin', 650, 464),
  (10, 'Deep Work', 'Cal Newport', 480, 296);
