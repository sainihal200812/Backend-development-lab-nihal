# Lab 1: Node.js and Express server

**Student Name:** Kollampally Sai Nihal  
**Registration Number:** 252U1R6104  
**Section:** AIML-IB  
**Course:** Backend Development Fundamentals · Year II Term II  
**Institution:** Aurora  
**Faculty:** Joel Prashanth D  

---

## Live Link
- **Deployment URL:** `Not applicable (Local execution / Ready for Render or Railway deployment)`  
> *Note:* If deployed to Render, Railway, or NxtWave Cloud IDE, replace this with your public URL (e.g., `https://your-app-name.onrender.com`). Postman / Browser test outputs and screenshots for every endpoint are provided below.

---

## How to Run

### 1. Prerequisites
- **Node.js** (v18.x or newer recommended, verified on v24.15.0)
- **npm** (v9.x or newer, verified on v11.12.1)

### 2. Installation
Navigate into the `lab-01` directory and install dependencies:
```bash
cd lab-01
npm install
```

### 3. Environment Variables
Create a `.env` file in the root of `lab-01/` based on `.env.example`:
```bash
PORT=3000
```
*(Never commit the real `.env` file to version control. It is ignored via `.gitignore`.)*

### 4. Start Commands

#### Run the Express Server (Tasks 4–7)
```bash
npm start
```
*Or during development with automatic reload:*
```bash
npm run dev
```

#### Run the Plain Node.js HTTP Server (Task 3)
```bash
npm run start:http
```

---

## Endpoints Table

| HTTP Method | Route | Description | Expected Status Code | Response Type |
|---|---|---|---|---|
| `GET` | `/` | Root route returning welcome message | `200 OK` | `text/html; charset=utf-8` |
| `GET` | `/about` | Returns student details (name, registration number, section) | `200 OK` | `application/json` |
| `GET` | `/time` | Returns current date and time generated via `new Date()` | `200 OK` | `application/json` |
| `GET` / `ALL` | `/*` *(e.g. `/random`)* | Custom 404 handler for any unregistered endpoint | `404 Not Found` | `application/json` |

---

## Screenshots

> Place your screenshots in the `screenshots/` directory using the filenames below.

### 1. Root Endpoint (`GET /`)
Responds with welcome text and status code `200 OK`.
![Root Endpoint](screenshots/01-root.png)

### 2. About Endpoint (`GET /about`)
Responds with student details in JSON format and status code `200 OK`.
![About Endpoint](screenshots/02-about.png)

### 3. Time Endpoint (`GET /time`)
Responds with current date and timestamps using `new Date()` and status code `200 OK`.
![Time Endpoint](screenshots/03-time.png)

### 4. 404 Error Handler (`GET /unknown-path`)
Responds with custom 404 error message and status code `404 Not Found`.
![404 Error Handler](screenshots/04-404.png)

### 5. Terminal Console Status Code Logs
Displays terminal output where request method, route, and response status codes are logged on completion.
![Console Status Code Logs](screenshots/05-console-status-logs.png)

---

## Task Details & Explanations

### Task 1: `package.json` Fields Explained
- **`name`**: The unique identifier/name of the project or package.
- **`version`**: The current semantic version of the project (`major.minor.patch`), e.g., `1.0.0`.
- **`description`**: A short summary of what the project does.
- **`main`**: The primary entry point file of the application (e.g., `index.js`).
- **`scripts`**: An object containing shortcut commands run via `npm run <script-name>` (e.g., `"start": "node index.js"`).
- **`keywords`**: An array of descriptive keywords used when searching npm packages.
- **`author`**: The creator or maintainer of the project.
- **`license`**: The legal open-source license governing code usage (e.g., `ISC`, `MIT`).
- **`dependencies`**: Production libraries required for the app to function (e.g., `express`).

### Task 2: Locating Express in `node_modules`
Running `npm install express` downloads Express and all of its transitive dependencies into the local `node_modules/` folder. The folder `node_modules/express/` contains:
- `lib/`: The core source code files implementing Express routing, request/response wrappers, and application logic.
- `index.js`: The entry point file exporting the Express library.
- `package.json`: Metadata specifying Express's own version, dependencies, and author.

### Task 3: Plain HTTP Server (`http-server.js`)
Built using Node.js's native `http` module:
```javascript
const http = require('http');
const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Hello');
});
server.listen(3000);
```

### Tasks 4–7: Express Server (`index.js`)
Built using Express with custom routes, status code logging middleware, and 404 fallback handling.

---

## Notes: Problems Faced and How You Solved Them

1. **Port Availability Conflict:**
   - *Problem:* Port 3000 might already be in use by another local development service (like React or another Node process).
   - *Solution:* Used dynamic port configuration with environment variable fallback: `const PORT = process.env.PORT || 3000;`. This allows running on alternative ports via `.env` or deployment environments without editing code.

2. **Preventing Sensitive Files & Large Dependencies from Git:**
   - *Problem:* `node_modules` contains thousands of files, and `.env` may contain environment-specific configuration that should never be pushed to a public repository.
   - *Solution:* Configured a strict `.gitignore` file ignoring `node_modules/`, `.env`, and log files before staging any git commits.

3. **Status Code Logging Requirement:**
   - *Problem:* Task 7 required logging which status code each route returns upon being accessed in the browser.
   - *Solution:* Implemented an Express middleware using `res.on('finish', ...)` to capture and log the response status code (`res.statusCode`) immediately when the HTTP response completes.

---

## Viva Questions & Answers

### 1. What is the difference between `package.json` and `node_modules`?
- **`package.json`**: A lightweight manifest file (metadata) that records project details, custom scripts, and lists the names and version ranges of project dependencies. It is committed to Git.
- **`node_modules`**: The directory that stores the actual installed code and binaries for all dependencies and their sub-dependencies. It is large and must never be committed to Git (it can be reproduced anytime via `npm install`).

### 2. What does `app.listen()` do?
`app.listen(port, [callback])` binds the Express application to a specific network port on the host machine and starts listening for incoming TCP/HTTP connection requests. Once listening, the optional callback function is triggered. Under the hood, Express creates a Node.js `http.Server` and calls its `.listen()` method.

### 3. What do `request` (`req`) and `response` (`res`) represent?
- **`req` (Request Object):** Represents the incoming HTTP request sent by the client. It contains details like HTTP method, URL path (`req.url` / `req.path`), headers, route parameters (`req.params`), query strings (`req.query`), and the request body (`req.body`).
- **`res` (Response Object):** Represents the outgoing HTTP response that the server sends back to the client. It provides methods to set HTTP status codes (`res.status()`), send headers (`res.set()`), send text/HTML (`res.send()`), or return formatted JSON (`res.json()`).
