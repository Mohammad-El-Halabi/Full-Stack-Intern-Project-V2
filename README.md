# Full Stack Intern Project v2 — Store Invoices

A basic e-commerce system that manages a store's **customers**, **items** and
**invoices**. Each customer can purchase multiple items per invoice. The result
is an admin app (Flutter) backed by a REST API (Spring Boot) and a MySQL
database, letting the store admin manage customers, items and create invoices.

The project has three parts, each in its own folder:

| Part | Folder      | What it is                                       |
|------|-------------|--------------------------------------------------|
| 1    | `database/` | MySQL 8 schema + seed data                       |
| 2    | `backend/`  | Spring Boot REST API                             |
| 3    | `frontend/` | Flutter admin app (Web / Windows / Android)      |

A ready-to-import **Postman** collection lives in `postman/`.

---

## Table of contents
1. [Technology stack](#technology-stack)
2. [Architecture & data model](#architecture--data-model)
3. [Prerequisites (required software)](#prerequisites-required-software)
4. [How to run locally — step by step](#how-to-run-locally--step-by-step)
   - [Part 1 — Database](#part-1--database-mysql)
   - [Part 2 — API](#part-2--api-spring-boot)
   - [Part 3 — Frontend](#part-3--frontend-flutter)
5. [Alternative: run backend + DB with Docker](#alternative-run-the-backend--database-with-docker-one-command)
6. [API endpoints](#api-endpoints)
7. [Suggested demo walkthrough](#suggested-demo-walkthrough)
8. [Troubleshooting](#troubleshooting)
9. [Project layout](#project-layout)

---

## Technology stack

| Layer        | Technology            | Version           | Notes                                       |
|--------------|-----------------------|-------------------|---------------------------------------------|
| Database     | MySQL                 | 8.x               | Managed with HeidiSQL                       |
| Backend lang | Java (JDK)            | 17                | Language level 17                           |
| Backend      | Spring Boot           | 3.2.3             | `spring-boot-starter-web`                   |
| Persistence  | Spring Data JPA       | (Boot-managed)    | Repositories + paging                       |
| ORM          | Hibernate             | 6.4.x             | Provided by Spring Data JPA                 |
| DB driver    | MySQL Connector/J     | (Boot-managed)    | `com.mysql:mysql-connector-j`               |
| Validation   | Jakarta Bean Validation | (Boot-managed)  | `spring-boot-starter-validation`            |
| Boilerplate  | Lombok                | (Boot-managed)    | Getters/setters/constructors                |
| Build tool   | Maven                 | 3.9.x             | Bundled with STS                            |
| Tests        | JUnit 5 + H2          | (Boot-managed)    | In-memory DB, no MySQL needed for tests     |
| Frontend     | Flutter               | 3.41 (stable)     | Material 3 UI                               |
| Frontend lang| Dart                  | 3.11+             | Comes with Flutter                          |
| HTTP client  | `http`                | ^1.2              | REST calls to the API                       |
| Formatting   | `intl`                | ^0.19             | Currency / date formatting                  |
| API testing  | Postman               | any               | Collection in `postman/`                    |
| (optional)   | Docker + Compose      | any recent        | One-command backend + DB                    |

---

## Architecture & data model

```
Flutter app  ──HTTP/JSON──►  Spring Boot REST API  ──JPA/JDBC──►  MySQL 8
 (frontend)                        (backend)                     (ecommerce_db)
   :chrome                          :8080                            :3306
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

`invoice_items` is the extra table that resolves the many-to-many relationship
between invoices and items. Per line it stores the **quantity**, the **unit
price at time of sale** (a snapshot, so later price changes never rewrite
history) and the **line total**. An invoice's `total_amount` is the sum of its
line totals.

### Backend layering
`controller` → `service` (business logic + `@Transactional`) → `repository`
(Spring Data JPA) → `entity`. Requests/responses use `dto` records; entities are
converted by `mapper`; errors go through a global `exception` handler that
returns a consistent JSON error body.

---

## Prerequisites (required software)

Install these before running (versions used during development in brackets):

| Software                               | Used for      | Download                                             |
|----------------------------------------|---------------|------------------------------------------------------|
| **MySQL 8 Server**                     | Part 1 DB     | https://dev.mysql.com/downloads/mysql/               |
| **HeidiSQL**                           | Part 1 GUI    | https://www.heidisql.com/download.php                |
| **JDK 17**                             | Part 2 API    | https://adoptium.net/temurin/releases/?version=17    |
| **Spring Tool Suite (STS)** or IntelliJ| Part 2 IDE    | https://spring.io/tools                              |
| **Maven 3.9+**                         | Part 2 build  | Bundled with STS (or https://maven.apache.org)       |
| **Postman**                            | Part 2 testing| https://www.postman.com/downloads/                   |
| **Flutter SDK** (3.11+ Dart)           | Part 3 app    | https://docs.flutter.dev/get-started/install         |
| **VS Code** or **Android Studio**      | Part 3 IDE    | https://code.visualstudio.com                        |

Check that the tools are visible from a terminal:

```bash
java -version        # should print 17.x
mvn -version         # should print Apache Maven 3.9.x
mysql --version      # should print 8.x
flutter --version    # should print Flutter 3.x, Dart 3.11+
```

> Prefer not to install JDK/Maven/MySQL? See the
> [Docker option](#alternative-run-the-backend--database-with-docker-one-command).

---

## How to run locally — step by step

Do the three parts **in order** (database → API → app). Keep each running in its
own terminal.

### Part 1 — Database (MySQL)

1. Install and start the **MySQL 8 server**. Note the `root` password you set
   during installation.
2. Open **HeidiSQL** and connect to your local server
   (Host `127.0.0.1`, Port `3306`, User `root`, your password).
3. Load and run the schema, then the seed data. **Using HeidiSQL:**
   - `File ▸ Load SQL file…` → pick `database/schema.sql` → press **F9** (or the
     blue ▶ "Execute" button) to run it. This creates the `ecommerce_db`
     database and all four tables.
   - `File ▸ Load SQL file…` → pick `database/seed.sql` → press **F9**. This adds
     the sample customers, items and invoices.

   **Or, using the command line** (from the project root):
   ```bash
   mysql -u root -p < database/schema.sql
   mysql -u root -p < database/seed.sql
   ```
4. Verify: in HeidiSQL, click the `ecommerce_db` database — you should see the
   tables `customers`, `items`, `invoices`, `invoice_items`, with 5 customers,
   8 items and 4 invoices.

### Part 2 — API (Spring Boot)

1. Open the `backend/` folder in **STS / IntelliJ** as an existing Maven project
   (STS: `File ▸ Import ▸ Maven ▸ Existing Maven Projects` → select `backend`).
2. Tell the API how to reach your database. Open
   `backend/src/main/resources/application.properties` and set your MySQL
   username/password if they are not `root`/`root`:
   ```properties
   spring.datasource.username=root
   spring.datasource.password=YOUR_MYSQL_PASSWORD
   ```
   (Or leave the file alone and set env vars `DB_USERNAME` / `DB_PASSWORD`.)
3. Run the API. **In the IDE:** right-click `EcommerceApiApplication.java`
   ▸ *Run As ▸ Spring Boot App*. **Or from a terminal:**
   ```bash
   cd backend
   mvn spring-boot:run
   ```
4. Wait for the log line `Started EcommerceApiApplication`. The API is now at
   **http://localhost:8080**. Open that URL in a browser — you should see a small
   JSON status page (`"status":"UP"`).
5. (Optional) **Test the endpoints in Postman:** `File ▸ Import` →
   `postman/Ecommerce-API.postman_collection.json`. Every request is pre-filled;
   just hit **Send**. Try *Invoices ▸ Create invoice (with all items)*.
6. (Optional) **Run the automated tests** (uses an in-memory H2 DB, so MySQL is
   not required for this): `cd backend && mvn test`.

### Part 3 — Frontend (Flutter)

1. Make sure the API (Part 2) is running.
2. In a new terminal:
   ```bash
   cd frontend
   flutter pub get        # download packages (first time only)
   flutter run -d chrome  # runs in Chrome
   ```
   Other targets: `flutter run -d windows` (desktop) or `flutter run` with an
   Android emulator/device selected.
3. The app opens with three sections in the navigation bar: **Customers**,
   **Items**, **Invoices**. It automatically talks to the API at
   `http://localhost:8080` (Android emulator uses `http://10.0.2.2:8080`).

**Pointing at a different API host** (e.g. a phone on your Wi-Fi):
```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8080
```

That's it — all three parts are running. 🎉

---

## Alternative: run the backend + database with Docker (one command)

If you have **Docker Desktop** and would rather not install JDK/Maven/MySQL,
start the whole backend stack (MySQL with schema+seed pre-loaded **and** the API)
from the project root:

```bash
docker compose up --build
```

- API → **http://localhost:8080**
- MySQL → **localhost:3306** (user `root`, password `root`, db `ecommerce_db`)

Then run the Flutter app as in [Part 3](#part-3--frontend-flutter). Stop with
`docker compose down` (add `-v` to also delete the database volume). This is a
convenience only; the manual setup above works identically.

---

## API endpoints

All list/read endpoints support paging via `?page=`, `?size=` and `?sort=` and
return a consistent envelope: `content`, `page`, `size`, `totalElements`,
`totalPages`, `first`, `last`.

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

**Create-invoice request body** (`POST /api/invoices`):
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
invoice. Rules enforced: customer and every item must exist, at least one line,
quantity ≥ 1, no duplicate item ids, and enough stock.

---

## Suggested demo walkthrough

A tight order for a demo video:

1. **Database** — show the four tables and seed rows in HeidiSQL.
2. **API in Postman** — run *Get all customers*, *Search items by name*,
   *Get all invoices by customer id*, then *Create invoice (with all items)* and
   show the returned totals.
3. **Flutter app**:
   - **Items** tab: search, create a new item, edit it, delete one.
   - **Customers** tab: search, create, edit, delete a customer.
   - **Invoices** tab: pick a customer → see their invoices → tap **New invoice**
     → add a few items with quantities → watch the live total → **Create** →
     see it appear in the list.
4. (Optional) Refresh HeidiSQL to show the new invoice + line items and the
   decremented item stock in the database.

---

## Troubleshooting

- **API won't start / "Access denied for user 'root'"** — the DB username or
  password in `application.properties` doesn't match your MySQL. Fix it there or
  via `DB_USERNAME` / `DB_PASSWORD` env vars.
- **API starts but "Schema validation" / "Table doesn't exist"** — you didn't run
  `schema.sql` yet, or ran it against the wrong server. Re-run Part 1. (The app
  uses `ddl-auto=validate`; if you'd rather have Hibernate create the tables,
  set `spring.jpa.hibernate.ddl-auto=update` in `application.properties`.)
- **Flutter app shows "Could not reach the server"** — the API isn't running, or
  the app is targeting the wrong host. Start the API first; on a real Android
  device pass `--dart-define=API_BASE_URL=http://YOUR_PC_IP:8080`.
- **Port already in use** — something else is on `8080` (API) or `3306` (MySQL).
  Stop it, or change `server.port` in `application.properties`.

---

## Project layout

```
Full-Stack-Intern-Project-V2/
├── README.md
├── docker-compose.yml            # optional one-command backend + DB
├── database/
│   ├── schema.sql                # creates ecommerce_db + 4 tables
│   └── seed.sql                  # sample data
├── backend/
│   ├── Dockerfile
│   ├── pom.xml
│   └── src/main/java/com/store/ecommerce/
│       ├── EcommerceApiApplication.java
│       ├── config/               # CORS
│       ├── controller/           # REST controllers
│       ├── dto/                  # request/response records + pagination
│       ├── entity/               # JPA entities
│       ├── exception/            # global error handling
│       ├── mapper/               # entity → DTO
│       ├── repository/           # Spring Data JPA
│       └── service/              # business logic
├── frontend/
│   └── lib/
│       ├── main.dart
│       ├── config/               # API base URL
│       ├── models/               # Customer, Item, Invoice, PageResponse
│       ├── services/             # ApiService HTTP client
│       ├── screens/              # customers, items, invoices + forms
│       ├── utils/                # formatting
│       └── widgets/              # shared list widget
└── postman/
    └── Ecommerce-API.postman_collection.json
```
