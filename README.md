# Full Stack Intern Project v2 — Store Invoices

A basic e-commerce system that manages a store's **customers**, **items** and
**invoices**. Each customer can purchase multiple items per invoice. The result
is an admin app (Flutter) backed by a REST API (Spring Boot) and a MySQL
database, letting the store admin manage customers, items and create invoices.

The project has three parts, each in its own folder:

| Part | Folder      | Tech                                             |
|------|-------------|--------------------------------------------------|
| 1    | `database/` | MySQL 8 schema + seed data                       |
| 2    | `backend/`  | Spring Boot 3.2.3, Spring Data JPA, Lombok, JDK 17 |
| 3    | `frontend/` | Flutter (runs on Web, Windows desktop, Android)  |

A ready-to-import **Postman** collection lives in `postman/`.

---

## Architecture at a glance

```
Flutter app  ──HTTP/JSON──►  Spring Boot REST API  ──JPA/JDBC──►  MySQL 8
 (frontend)                        (backend)                     (ecommerce_db)
```

### Data model

```
customers ──1─────< invoices ──1─────< invoice_items >─────1── items
   id                  id                  id                    id
   name                customer_id (FK)    invoice_id (FK)       name
   email               invoice_date        item_id (FK)          description
   phone               total_amount        quantity              price
   address             status              unit_price            stock_quantity
                                            line_total
```

`invoice_items` resolves the many-to-many relationship between invoices and
items. It stores the **quantity**, the **unit price at time of sale** (a
snapshot, so later price changes never rewrite history) and the **line total**.
An invoice's `total_amount` is the sum of its line totals.

---

## Part 1 — Database (MySQL 8 / HeidiSQL)

Files in `database/`:

- `schema.sql` — creates the `ecommerce_db` schema and all tables (with keys,
  foreign keys, indexes and check constraints).
- `seed.sql` — inserts demo customers, items and invoices so the API/app have
  data to show immediately.

**Run it** (HeidiSQL: open the file and press *Run*, or from the command line):

```bash
mysql -u root -p < database/schema.sql
mysql -u root -p < database/seed.sql
```

---

## Part 2 — API (Spring Boot)

### Requirements
- JDK 17
- Maven (bundled with STS, or standalone)
- A running MySQL 8 with `ecommerce_db` created (Part 1)

### Configure the database connection
Defaults live in `backend/src/main/resources/application.properties` and can be
overridden with environment variables:

| Variable      | Default                                                       |
|---------------|---------------------------------------------------------------|
| `DB_URL`      | `jdbc:mysql://localhost:3306/ecommerce_db?...`                |
| `DB_USERNAME` | `root`                                                        |
| `DB_PASSWORD` | `root`                                                        |

> The app uses `spring.jpa.hibernate.ddl-auto=validate`, so it expects the
> tables from `schema.sql` to already exist. If you'd rather have Hibernate
> create the tables for you, change that property to `update`.

### Run

```bash
cd backend
mvn spring-boot:run
```

The API starts on **http://localhost:8080**. Run the tests with `mvn test`
(they use an in-memory H2 database, so no MySQL is needed for testing).

### Endpoints

All list/read endpoints support paging via `?page=`, `?size=` and `?sort=`
query parameters and return a consistent pagination envelope
(`content`, `page`, `size`, `totalElements`, `totalPages`, `first`, `last`).

**Customers** — `/api/customers`
| Method | Path                          | Description                          |
|--------|-------------------------------|--------------------------------------|
| GET    | `/api/customers`              | Get all customers (paged)            |
| GET    | `/api/customers/search?name=` | **Search for customers by name**     |
| GET    | `/api/customers/{id}`         | Get one customer                     |
| GET    | `/api/customers/{id}/invoices`| **Get all invoices by customer id**  |
| POST   | `/api/customers`              | Create a customer                    |
| PUT    | `/api/customers/{id}`         | Update a customer                    |
| DELETE | `/api/customers/{id}`         | Delete a customer                    |

**Items** — `/api/items`
| Method | Path                      | Description                    |
|--------|---------------------------|--------------------------------|
| GET    | `/api/items`              | Get all items (paged)          |
| GET    | `/api/items/search?name=` | **Search for items by name**   |
| GET    | `/api/items/{id}`         | Get one item                   |
| POST   | `/api/items`              | Create an item                 |
| PUT    | `/api/items/{id}`         | Update an item                 |
| DELETE | `/api/items/{id}`         | Delete an item                 |

**Invoices** — `/api/invoices`
| Method | Path                                    | Description                                   |
|--------|-----------------------------------------|-----------------------------------------------|
| GET    | `/api/invoices`                         | Get all invoices (paged)                      |
| GET    | `/api/invoices/search?customerName=`    | **Get all invoices by the customer's name**   |
| GET    | `/api/invoices/by-customer/{customerId}`| **Get all invoices by customer id**           |
| GET    | `/api/invoices/{id}`                    | Get one invoice                               |
| POST   | `/api/invoices`                         | **Create an invoice including all its items** |
| PUT    | `/api/invoices/{id}`                    | Update an invoice (replaces its lines)        |
| DELETE | `/api/invoices/{id}`                    | Delete an invoice                             |

#### Create-invoice request (the single endpoint that creates an invoice with all its items)
`POST /api/invoices`
```json
{
  "customerId": 1,
  "items": [
    { "itemId": 1, "quantity": 2 },
    { "itemId": 3, "quantity": 5 }
  ]
}
```
The server looks up each item, snapshots its current price, computes each line
total and the invoice total, decrements item stock, and returns the full
invoice. Business rules enforced: the customer and every item must exist, an
invoice needs at least one line, quantities are ≥ 1, an item can't appear twice,
and there must be enough stock.

Import `postman/Ecommerce-API.postman_collection.json` into Postman to try every
endpoint (set the `baseUrl` variable if not using `http://localhost:8080`).

---

## Part 3 — Frontend (Flutter)

A Material 3 admin app that manages customers, items and invoices.

- **Items** — view all, search, create, edit, delete.
- **Customers** — view all, search, create, edit, delete.
- **Invoices** — pick a customer to view all their invoices (by customer id),
  and create new invoices by adding items with quantities and a live total.

### Requirements
- Flutter SDK (Dart 3.11+)

### Run
Make sure the backend (Part 2) is running first, then:

```bash
cd frontend
flutter pub get
flutter run -d chrome      # or: -d windows, or an Android emulator/device
```

### Pointing the app at the API
`lib/config/api_config.dart` chooses the base URL automatically:
- Web / Windows desktop → `http://localhost:8080`
- Android emulator → `http://10.0.2.2:8080` (the emulator's alias for the host)

To point at another host (e.g. a phone on your network), pass it at run time:
```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8080
```

---

## Project layout

```
Full-Stack-Intern-Project-V2/
├── database/
│   ├── schema.sql
│   └── seed.sql
├── backend/
│   ├── pom.xml
│   └── src/main/java/com/store/ecommerce/
│       ├── EcommerceApiApplication.java
│       ├── config/         (CORS)
│       ├── controller/     (REST controllers)
│       ├── dto/            (request/response records + pagination)
│       ├── entity/         (JPA entities)
│       ├── exception/      (error handling)
│       ├── mapper/         (entity → DTO)
│       ├── repository/     (Spring Data JPA)
│       └── service/        (business logic)
├── frontend/
│   └── lib/
│       ├── main.dart
│       ├── config/         (API base URL)
│       ├── models/         (Customer, Item, Invoice, PageResponse)
│       ├── services/       (ApiService HTTP client)
│       ├── screens/        (customers, items, invoices + forms)
│       ├── utils/          (formatting)
│       └── widgets/        (shared list widget)
└── postman/
    └── Ecommerce-API.postman_collection.json
```

## Quick start (all three parts)

```bash
# 1. Database
mysql -u root -p < database/schema.sql
mysql -u root -p < database/seed.sql

# 2. API
cd backend && mvn spring-boot:run      # http://localhost:8080

# 3. App (in another terminal)
cd frontend && flutter pub get && flutter run -d chrome
```
