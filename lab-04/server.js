/**
 * Lab 4: Registration, login and JWT
 * Backend Development Fundamentals · Year II Term II · Aurora
 * Faculty: Yugandhar Gurjalwar
 * Student Name: K SAI NIHAL
 * Registration Number: 252U1R6104
 * Section: AIML-2B
 */

const express = require('express');
const fs = require('fs');
const path = require('path');
const cors = require('cors');
require('dotenv').config();

// Task 1: Install bcrypt and jsonwebtoken; add app.use(express.json()) so the body can be read
let bcrypt;
try {
  bcrypt = require('bcrypt');
} catch (err) {
  bcrypt = require('bcryptjs');
}
const jwt = require('jsonwebtoken');

const app = express();
app.use(cors());
app.use(express.json());

// Request logger middleware
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[LOG] ${req.method} ${req.originalUrl} -> Status: ${res.statusCode} (${duration}ms)`);
  });
  next();
});

// Task 5: Put secret key in a constant for now (moved to .env in Lab 8)
const SECRET_KEY = process.env.JWT_SECRET || 'MY_SECRET_TOKEN';

// In-Memory Database Adapter for Serverless Environments (Vercel / Lambda)
class ServerlessUserDbAdapter {
  constructor() {
    this.users = [];
  }

  async get(sql, params = []) {
    const username = params[0];
    return this.users.find((u) => u.username === username);
  }

  async run(sql, params = []) {
    const [username, name, password] = params;
    const existingIndex = this.users.findIndex((u) => u.username === username);
    if (existingIndex >= 0) {
      this.users[existingIndex] = { username, name, password };
    } else {
      this.users.push({ username, name, password });
    }
    return { changes: 1 };
  }

  async all(sql) {
    return this.users.map((u) => ({
      username: u.username,
      name: u.name,
      password_hash_preview: u.password.substring(0, 15) + '...',
    }));
  }
}

let db = null;
let dbPromise = null;

const getDBInstance = async () => {
  if (db) return db;
  if (!dbPromise) {
    dbPromise = (async () => {
      // If running on Vercel serverless where native sqlite binary may not compile
      if (process.env.VERCEL) {
        db = new ServerlessUserDbAdapter();
        return db;
      }

      try {
        const { open } = require('sqlite');
        const sqlite3 = require('sqlite3');
        const dbPath = process.env.DB_PATH || path.join(__dirname, 'userData.db');

        const dbInstance = await open({
          filename: dbPath,
          driver: sqlite3.Database,
        });

        // Task 2: Create a user table with a unique username, name and a password column that stores the hash
        await dbInstance.exec(`
          CREATE TABLE IF NOT EXISTS user (
            username TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            password TEXT NOT NULL
          );
        `);

        db = dbInstance;
        return db;
      } catch (err) {
        console.warn('Native SQLite unavailable, using serverless user adapter:', err.message);
        db = new ServerlessUserDbAdapter();
        return db;
      }
    })();
  }
  return dbPromise;
};

// Start local listener only if not running inside a serverless handler
if (!process.env.VERCEL) {
  const PORT = process.env.PORT || 3000;
  getDBInstance().then(() => {
    app.listen(PORT, () => {
      console.log(`Server Running at http://localhost:${PORT}/`);
    });
  });
}

// Root endpoint: API health check & lab info
app.get('/', (req, res) => {
  res.status(200).json({
    status: 'success',
    lab: 'Lab 4: Registration, login and JWT',
    faculty: 'Yugandhar Gurjalwar',
    student: 'K SAI NIHAL',
    registrationNumber: '252U1R6104',
    section: 'AIML-2B',
    endpoints: [
      { method: 'POST', path: '/register/', description: 'Register a new user with hashed password' },
      { method: 'POST', path: '/login/', description: 'Authenticate user and receive JWT token' },
      { method: 'GET', path: '/users/', description: 'Inspect stored user accounts (excluding sensitive hash)' }
    ]
  });
});

// Helper for register logic (supports both /register and /register/)
const handleRegister = async (req, res) => {
  const { username, name, password } = req.body;

  if (!username || !password || !name) {
    return res.status(400).send('Username, name, and password are required');
  }

  try {
    const activeDb = await getDBInstance();

    // Task 3: Check if username already exists using parameterized query
    const selectUserQuery = `SELECT * FROM user WHERE username = ?;`;
    const dbUser = await activeDb.get(selectUserQuery, [username]);

    if (dbUser !== undefined) {
      // Reject existing username with 400
      return res.status(400).send('User already exists');
    }

    // Hash the password with bcrypt.hash (salt rounds = 10)
    const hashedPassword = await bcrypt.hash(password, 10);

    // Save the user with parameterized query
    const createUserQuery = `
      INSERT INTO user (username, name, password)
      VALUES (?, ?, ?);
    `;
    await activeDb.run(createUserQuery, [username, name, hashedPassword]);

    return res.status(200).send('User created successfully');
  } catch (error) {
    console.error('Register error:', error.message);
    return res.status(500).send('Internal Server Error');
  }
};

// Task 3: POST /register/ & /register
app.post('/register', handleRegister);
app.post('/register/', handleRegister);

// Helper for login logic (supports both /login and /login/)
const handleLogin = async (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.status(400).send('Username and password are required');
  }

  try {
    const activeDb = await getDBInstance();

    // Check if user exists using parameterized query
    const selectUserQuery = `SELECT * FROM user WHERE username = ?;`;
    const dbUser = await activeDb.get(selectUserQuery, [username]);

    // Task 4: return 400 for an unknown user
    if (dbUser === undefined) {
      return res.status(400).send('Invalid user');
    }

    // Compare the password with bcrypt.compare
    const isPasswordMatched = await bcrypt.compare(password, dbUser.password);

    // Task 4: return 400 for a wrong password
    if (!isPasswordMatched) {
      return res.status(400).send('Invalid password');
    }

    // Task 5: Put only the username (never the password) in the token payload
    const payload = {
      username: username,
    };

    // Task 4: on success return { jwt_token } created with jwt.sign
    const jwtToken = jwt.sign(payload, SECRET_KEY);
    return res.status(200).json({ jwt_token: jwtToken });
  } catch (error) {
    console.error('Login error:', error.message);
    return res.status(500).send('Internal Server Error');
  }
};

// Task 4: POST /login/ & /login
app.post('/login', handleLogin);
app.post('/login/', handleLogin);

// Database view / verification endpoint (non-sensitive fields)
app.get('/users', async (req, res) => {
  try {
    const activeDb = await getDBInstance();
    const getUsersQuery = `SELECT username, name, substr(password, 1, 15) || '...' AS password_hash_preview FROM user;`;
    const users = await activeDb.all(getUsersQuery);
    return res.status(200).json(users);
  } catch (error) {
    return res.status(500).send('Internal Server Error');
  }
});
app.get('/users/', (req, res) => res.redirect('/users'));

module.exports = app;
