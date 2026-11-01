# Screenshots Guide for Lab 1

Save your screenshots in this folder with the following filenames:

1. **`01-root.png`**:
   - Browser or Postman showing `http://localhost:3000/`
   - Should display: `Welcome to Backend Development Fundamentals - Lab 1 Server!`
   - Status code: `200 OK`

2. **`02-about.png`**:
   - Browser or Postman showing `http://localhost:3000/about`
   - Should display JSON with your name, registration number, and section.
   - Status code: `200 OK`

3. **`03-time.png`**:
   - Browser or Postman showing `http://localhost:3000/time`
   - Should display JSON with current date, ISO string, UTC, and timestamp.
   - Status code: `200 OK`

4. **`04-404.png`**:
   - Browser or Postman showing an invalid path like `http://localhost:3000/unknown`
   - Should display the 404 JSON error message.
   - Status code: `404 Not Found`

5. **`05-console-status-logs.png`**:
   - Terminal window running `npm start` displaying the logged request lines, e.g.:
     ```text
     [LOG] GET / -> Status: 200 (8ms)
     [LOG] GET /about -> Status: 200 (1ms)
     [LOG] GET /time -> Status: 200 (1ms)
     [LOG] GET /unknown-path -> Status: 404 (1ms)
     ```
