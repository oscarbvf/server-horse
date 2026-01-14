# ServerHorse

## Overview

**ServerHorse** is a lightweight RESTful backend service built with **Delphi** using the **Horse framework**.

The project demonstrates how to build a clean and minimal REST API in Delphi, including routing, request handling, persistence, and basic layering. It is designed as a technical and educational project, not as a production-ready system.

---

## Purpose

The main goals of this project are:

- To demonstrate REST API development in Delphi using Horse
- To showcase a simple but structured backend architecture
- To integrate with a desktop client application (**ClientVCL**)
- To serve as a backend reference project within a Delphi portfolio

---

## Key Features

- RESTful API built with **Horse**
- Clear routing and controller organization
- Persistence using **SQLite**
- Database access via **FireDAC**
- Automatic database initialization on first run
- JSON-based request and response payloads
- Tested using **Postman** and `curl`

---

## Architecture (High-Level)

The project follows a straightforward layered structure:

- **API Layer**
  - Horse server configuration
  - Route definitions and request/response handling

- **Controller Layer**
  - Endpoint logic
  - Validation and response formatting

- **Persistence Layer**
  - FireDAC configuration
  - SQLite database access
  - Simple repository-style access

This structure keeps HTTP concerns separated from data access logic.

---

## Technologies Used

- Delphi (RAD Studio – modern versions)
- Horse framework
- FireDAC
- SQLite
- JSON (System.JSON)
- Windows platform

---

## Project Structure (Simplified)

# ServerHorse

## Overview

**ServerHorse** is a lightweight RESTful backend service built with **Delphi** using the **Horse framework**.

The project demonstrates how to build a clean and minimal REST API in Delphi, including routing, request handling, persistence, and basic layering. It is designed as a technical and educational project, not as a production-ready system.

---

## Purpose

The main goals of this project are:

- To demonstrate REST API development in Delphi using Horse
- To showcase a simple but structured backend architecture
- To integrate with a desktop client application (**ClientVCL**)
- To serve as a backend reference project within a Delphi portfolio

---

## Key Features

- RESTful API built with **Horse**
- Clear routing and controller organization
- Persistence using **SQLite**
- Database access via **FireDAC**
- Automatic database initialization on first run
- JSON-based request and response payloads
- Tested using **Postman** and `curl`

---

## Architecture (High-Level)

The project follows a straightforward layered structure:

- **API Layer**
  - Horse server configuration
  - Route definitions and request/response handling

- **Controller Layer**
  - Endpoint logic
  - Validation and response formatting

- **Persistence Layer**
  - FireDAC configuration
  - SQLite database access
  - Simple repository-style access

This structure keeps HTTP concerns separated from data access logic.

---

## Technologies Used

- Delphi (RAD Studio – modern versions)
- Horse framework
- FireDAC
- SQLite
- JSON (System.JSON)
- Windows platform

---

## Project Structure (Simplified)

ServerHorse/
├── ServerHorse.dpr
├── ServerHorse.dproj
├── Controllers/
│ └── *.pas
├── Models/
│ └── *.pas
├── Data/
│ └── Database.db
├── Services/
│ └── *.pas
└── README.md


> Folder names may evolve as the project grows.

---

## Database

- Database engine: **SQLite**
- Database file: `database.db`
- The database and required tables are created automatically on first run.

No manual setup is required.

---

## API Overview

Example endpoints:

- `GET /clientes`  
  Returns a list of clients

- `POST /clientes`  
  Creates a new client

Payloads are JSON-based.

---

## How to Run

1. Open `ServerHorse.dproj` in Delphi
2. Build and run the project
3. The server will start listening on the configured port
4. Use Postman or `curl` to test the endpoints

Example using `curl`:
curl http://localhost:9000/clientes

## Scope and Limitations

- Authentication and authorization are not implemented
- Validation is minimal and focused on demonstration
- Error handling is basic
- Not intended for production use

---

## Related Projects

This repository is part of a Delphi portfolio composed of multiple independent projects:

- **HelloModernDelphi** – Modern Delphi language features showcase
- **ClientVCL** – VCL desktop client consuming this API

Projects are connected via a portfolio aggregator repository.

---

## License

This project is provided for educational and demonstration purposes.
