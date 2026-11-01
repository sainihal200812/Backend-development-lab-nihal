# Backend Development Fundamentals — Lab Repository

**Student Name:** Kollampally Sai Nihal  
**Registration Number:** 252U1R6104  
**Section:** AIML-IB  
**Institution:** Aurora  
**Faculty:** Joel Prashanth D  
**Course:** Backend Development Fundamentals (Year II Term II)

---

## Repository Structure & Overview

This repository hosts all laboratory assignments for the **Backend Development Fundamentals** course, organized with one folder per lab (`lab-01` … `lab-10`) as required by the course syllabus.

Each lab folder is self-contained with its own source code, dependencies manifest (`package.json`), documentation (`README.md`), and output verification screenshots (`screenshots/`).

| Lab Folder | Title | Module / Topic | Status |
|---|---|---|---|
| [`lab-01/`](./lab-01/) | **Node.js and Express server** | Node.js & Express.js fundamentals, routing, status codes | Completed |
| `lab-02/` | *Routing and Middleware* | HTTP methods, middleware chain, request logging | Upcoming |
| `lab-03/` | *RESTful APIs & Controllers* | REST principles, URL params, query strings | Upcoming |
| `lab-04/` | *Data Validation & Error Handling* | Schema validation, central error handling | Upcoming |
| `lab-05/` | *Database Connectivity* | Database integration, ORM/ODM models | Upcoming |
| `lab-06/` | *CRUD Operations* | Full CRUD lifecycle, parameterized queries | Upcoming |
| `lab-07/` | *Authentication & Authorization* | Passwords hashing (bcrypt), JWT sessions | Upcoming |
| `lab-08/` | *File Uploads & Static Serving* | Multer, multi-part form data, file storage | Upcoming |
| `lab-09/` | *Third-Party APIs & Async Workflows* | Axios/fetch, webhooks, asynchronous background tasks | Upcoming |
| `lab-10/` | *Deployment & Production Best Practices* | Production environment, security headers, rate limiting | Upcoming |

---

## Course Guidelines & Rules Followed
1. **Never commit `.env` files**: All secrets and local configurations stay local; `.env.example` templates are provided.
2. **Never commit `node_modules`**: All dependencies are managed cleanly through `package.json` and `.gitignore`.
3. **Appropriate HTTP Status Codes**: Every endpoint returns semantic status codes (`200 OK`, `404 Not Found`, etc.).
4. **Parameterized Data Handling**: SQL / NoSQL operations strictly avoid plain string concatenation to prevent injection.
5. **Academic Integrity**: All solutions are built and documented step-by-step for full viva clarity.
