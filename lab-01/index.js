/**
 * Lab 1: Node.js and Express server
 * Course: Backend Development Fundamentals · Year II Term II · Aurora
 * Faculty: Joel Prashanth D
 * Tasks 4, 5, 6, 7: Express server with routes, 404 handler, and status code logging
 */

const express = require('express');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware: Request logger to log each route and its returned status code (Task 7)
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[LOG] ${req.method} ${req.originalUrl} -> Status: ${res.statusCode} (${duration}ms)`);
  });
  next();
});

// Task 5 - Route 1: GET / (welcome text)
app.get('/', (req, res) => {
  res.status(200).send('Welcome to Backend Development Fundamentals - Lab 1 Server!');
});

// Task 5 - Route 2: GET /about (JSON with name and section)
app.get('/about', (req, res) => {
  res.status(200).json({
    name: 'Kollampally Sai Nihal',
    registrationNumber: '252U1R6104',
    section: 'AIML-IB',
    course: 'Backend Development Fundamentals',
    faculty: 'Joel Prashanth D'
  });
});

// Task 5 - Route 3: GET /time (current date and time using new Date())
app.get('/time', (req, res) => {
  const now = new Date();
  res.status(200).json({
    message: 'Current Server Date and Time',
    iso: now.toISOString(),
    utc: now.toUTCString(),
    local: now.toString(),
    timestamp: now.getTime()
  });
});

// Task 6: Return a 404 message for any unknown path
app.use((req, res) => {
  res.status(404).json({
    error: '404 Not Found',
    message: `Cannot ${req.method} ${req.originalUrl} - The requested resource was not found on this server.`,
    statusCode: 404
  });
});

// Task 4: Start listening on port 3000 (or process.env.PORT)
app.listen(PORT, () => {
  console.log(`Express server running at http://localhost:${PORT}`);
  console.log('Available endpoints:');
  console.log(`  - GET http://localhost:${PORT}/       (Welcome text)`);
  console.log(`  - GET http://localhost:${PORT}/about  (Student JSON details)`);
  console.log(`  - GET http://localhost:${PORT}/time   (Current date & time)`);
});
