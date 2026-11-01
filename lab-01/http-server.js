/**
 * Lab 1 - Task 3: Plain Node.js HTTP Server
 * Built with the built-in 'http' module
 */

const http = require('http');

const PORT = process.env.PORT || 3000;

// Create server with http.createServer that replies "Hello"
const server = http.createServer((req, res) => {
  console.log(`[HTTP Server] ${req.method} ${req.url} - Responding with 'Hello'`);
  res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
  res.end('Hello');
});

// Listen on port 3000
server.listen(PORT, () => {
  console.log(`Plain HTTP server running at http://localhost:${PORT}/`);
});
