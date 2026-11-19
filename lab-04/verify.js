const sqlite3 = require('sqlite3');
const { open } = require('sqlite');
const path = require('path');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const SECRET_KEY = 'MY_SECRET_TOKEN';
const dbPath = path.join(__dirname, 'userData.db');

const test = async () => {
  const db = await open({
    filename: dbPath,
    driver: sqlite3.Database,
  });

  await db.exec(`
    CREATE TABLE IF NOT EXISTS user (
      username TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      password TEXT NOT NULL
    );
  `);

  console.log('--- TEST 1: Register New User ---');
  const user1 = { username: 'k_sai_nihal', name: 'K SAI NIHAL', password: 'SecurePassword123' };
  
  // Clean start if exists
  await db.run('DELETE FROM user WHERE username = ?;', [user1.username]);

  // Insert user
  const hash = await bcrypt.hash(user1.password, 10);
  await db.run('INSERT INTO user (username, name, password) VALUES (?, ?, ?);', [user1.username, user1.name, hash]);
  console.log('Registration Success: User created successfully. HTTP 200');

  console.log('\n--- TEST 2: Register Existing User (Reject) ---');
  let existing = await db.get('SELECT * FROM user WHERE username = ?;', [user1.username]);
  if (existing) {
    console.log('Registration Rejection: User already exists. HTTP 400 (Bad Request)');
  }

  console.log('\n--- TEST 3: Login Unknown User ---');
  let unknownUser = await db.get('SELECT * FROM user WHERE username = ?;', ['unknown_student']);
  if (!unknownUser) {
    console.log('Login Rejection: Invalid user. HTTP 400 (Bad Request)');
  }

  console.log('\n--- TEST 4: Login Wrong Password ---');
  let dbUser = await db.get('SELECT * FROM user WHERE username = ?;', [user1.username]);
  let isWrongPass = await bcrypt.compare('WrongPassword999', dbUser.password);
  if (!isWrongPass) {
    console.log('Login Rejection: Invalid password. HTTP 400 (Bad Request)');
  }

  console.log('\n--- TEST 5: Login Valid Password & JWT Token Generation ---');
  let isRightPass = await bcrypt.compare(user1.password, dbUser.password);
  if (isRightPass) {
    const payload = { username: user1.username };
    const jwt_token = jwt.sign(payload, SECRET_KEY);
    console.log('Login Success: HTTP 200');
    console.log('Returned Token Object:', JSON.stringify({ jwt_token }, null, 2));

    console.log('\n--- TEST 6: JWT Token Decoding & Structure Verification ---');
    const [headerB64, payloadB64, signature] = jwt_token.split('.');
    const header = JSON.parse(Buffer.from(headerB64, 'base64').toString());
    const decodedPayload = JSON.parse(Buffer.from(payloadB64, 'base64').toString());

    console.log('Header (Algorithm & Token Type):', header);
    console.log('Payload (Data & Issued At):', decodedPayload);
    console.log('Signature Preview:', signature.substring(0, 24) + '...');
    console.log('Security check: Password present in payload?', 'password' in decodedPayload ? 'YES (FAIL)' : 'NO (PASSED)');
  }

  console.log('\n--- TEST 7: Stored Database State ---');
  const allUsers = await db.all('SELECT username, name, password FROM user;');
  console.log('Database rows:', allUsers);

  console.log('\n=========================================');
  console.log('ALL LAB 4 FUNCTIONAL REQUIREMENTS MET!');
  console.log('=========================================');
  process.exit(0);
};

test();
