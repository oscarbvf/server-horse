# ServerHorse

## Overview

**ServerHorse** is a lightweight RESTful backend service built with **Delphi (RAD Studio)** using the **Horse framework**.

The project demonstrates how to design and implement a structured REST API in Delphi, including routing, controller separation, business rules encapsulation, and database persistence.

This is a technical portfolio project focused on architecture, layering, and clean separation of concerns — not a production-ready system.

---

## Purpose

The main goals of this project are:

- Demonstrate REST API development in Delphi using Horse
- Apply layered architecture principles
- Separate HTTP concerns from business logic and persistence
- Integrate with a desktop client application (**ClientVCL**)
- Serve as a backend reference project in a Delphi portfolio

---

## Key Features

- RESTful API built with Horse
- Explicit separation of:
  - Routing / HTTP layer
  - Controllers
  - Services (business rules)
  - Persistence layer
- Business rule validation:
  - Email format validation
  - Duplicate email prevention
- SQLite database
- Data access via FireDAC
- Automatic database initialization on first run
- Transactional and idempotent schema creation
- JSON-based request and response payloads
- Tested using Postman and `curl`

---

## Architecture

The project follows a layered architecture with clear responsibility boundaries.

### 1. API Layer

- Horse server configuration
- Middleware setup
- Route registration

### 2. Controller Layer

- Handles HTTP requests and responses
- Parses and validates input parameters
- Delegates business rules to the Service layer
- Returns proper HTTP status codes

### 3. Service Layer

- Encapsulates business logic
- Performs domain validation
- Ensures rules such as:
  - Valid email format
  - Email uniqueness
- Orchestrates persistence operations

### 4. Persistence Layer

- FireDAC configuration
- SQLite connection management
- Data access operations
- Database initialization and schema creation

This structure ensures:

- Controllers are HTTP-focused  
- Services are business-focused  
- DataModule is infrastructure-focused  

---

## Technologies Used

- Delphi (Modern RAD Studio versions)
- Horse framework
- FireDAC
- SQLite
- System.JSON
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

- Engine: SQLite
- Database file: `database.db`
- Automatically initialized at application startup

## Connection Management & Initialization Strategy

The project implements a controlled database initialization and connection lifecycle strategy:

### Application Startup Initialization

At application startup:

- The FireDAC `ConnectionDefName` and connection parameters are configured
- The database schema is verified and created (if necessary)
- Schema creation runs inside a transaction
- Idempotent SQL (`CREATE TABLE IF NOT EXISTS`) is used

This initialization logic runs **only once**, during application bootstrap.

---

### Request-Scoped DataModule

For each HTTP request:

- A new `DataModule` instance is created
- The `TFDConnection` component is reused (not recreated)
- The connection definition is not reconfigured per request

This ensures:

- Clear separation between application initialization and request processing
- Infrastructure isolation per request
- Predictable lifecycle management
- Reduced overhead by avoiding repeated connection configuration

---

### Design Considerations

The implementation follows these principles:

- Database configuration is application-level concern
- Business logic remains isolated from infrastructure setup
- Controllers do not manage connection lifecycle
- DataModule acts strictly as infrastructure boundary

This approach keeps the architecture simple while avoiding common anti-patterns such as:

- Reconfiguring the database connection on every request
- Mixing HTTP concerns with persistence setup
- Performing schema creation during request handling

---

## API Overview

The ServerHorse project exposes a RESTful API for managing clients.

All endpoints use JSON for request and response payloads.

### Base URL

http://localhost:9000


### Endpoints

### GET /clientes

Returns a list of all registered clients.

**Response**

- `200 OK`
- JSON array of client objects

---

### GET /clientes/{id}

Returns a single client by its identifier.

**Parameters**

- `id` (integer)

**Response**

- `200 OK` – Client found  
- `404 Not Found` – Client does not exist  

---

### POST /clientes

Creates a new client.

**Request body**

``` json
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

``` json
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
3. The server will start listening on the configured port (default: 9000)
4. Use Postman or `curl` to test the endpoints

Example using `curl`:
curl http://localhost:9000/clientes


## Scope and Limitations

- No authentication or authorization
- No pagination
- No logging middleware
- Minimal error abstraction
- No automated tests
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
