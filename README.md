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

```
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
├── modules/
│ └── horse
│ └──── (horse files)
└── README.md
```

> Folder names may evolve as the project grows.

---

## Database

- Database engine: **SQLite**
- Database file: `database.db`
- The application automatically initializes the SQLite database at startup

- Connection configuration is isolated from schema initialization
- Required tables are created inside a transaction
- Schema creation uses idempotent SQL (`CREATE TABLE IF NOT EXISTS`)

---

## API Overview

The ServerHorse project exposes a simple RESTful API for managing clients.
All endpoints use JSON for request and response payloads.

### Endpoints

#### GET /clientes

Returns a list of all registered clients.

**Response**
- `200 OK`
- JSON array of client objects


#### GET /clientes/{id}

Returns a single client by its identifier.

**Parameters**
- `id` (integer) – Client identifier

**Response**
- `200 OK` – Client found
- `404 Not Found` – Client does not exist


#### POST /clientes

Creates a new client.

**Request body**
```
{
  "nome": "Jane Doe",
  "email": "jane.doe@email.com",
  "telefone": "+55 21 98888-8888"
}
```

**Response**
- `201 Created`
- Returns the created client object


#### PUT /clientes/{id}

Updates an existing client.

**Parameters**

- `id` (integer) – Client identifier

**Request body**
```
{
  "nome": "Jane Doe Updated",
  "email": "jane.updated@email.com",
  "telefone": "+55 21 97777-7777"
}
```

**Response**
- `200 OK`
- `404 Not Found`


#### DELETE /clientes/{id} ####

Deletes a client.

**Parameters**
- `id` (integer) – Client identifier

**Response**
- `204 No Content`
- `404 Not Found`

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
