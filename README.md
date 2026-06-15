# 🏟️ Football Ticket Booking System

A relational database design and SQL query project built with **PostgreSQL**, simulating a real-world football ticket booking platform. This project includes full schema design, ERD relationships, sample data seeding, and intermediate-to-advanced SQL queries.

---

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Database Schema (ERD)](#-database-schema-erd)
- [Table Definitions](#-table-definitions)
- [Setup & Installation](#-setup--installation)
- [SQL Queries (Part 2)](#-sql-queries-part-2)
- [Sample Data](#-sample-data)
- [Author](#-author)

---

## 📌 Project Overview

This project implements a simplified **Football Ticket Booking System** database that manages:

- 👤 **Users** — Football fans and ticket managers registered on the platform
- ⚽ **Matches** — Upcoming tournament fixtures with pricing and availability status
- 🎟️ **Bookings** — Transactional records linking users to their purchased match tickets

**Key Learning Objectives:**

- Design an ERD with 1-to-1, 1-to-Many, and Many-to-1 relationships
- Understand Primary Keys, Foreign Keys, and Referential Integrity
- Write complex SQL queries using JOINs, subqueries, aggregations, pattern matching, NULL handling, and pagination

---

## 🛠️ Tech Stack

| Tool                     | Purpose                                         |
| ------------------------ | ----------------------------------------------- |
| **PostgreSQL**           | Relational Database Management System           |
| **SQL**                  | Schema definition (DDL) and data querying (DML) |
| **Lucidchart / Draw.io** | ERD Design                                      |
| **GitHub**               | Version control and submission                  |

---

## 📁 Project Structure

```
football-ticket-booking/
│
├── README.md           ← Project documentation (this file)
└── QUERY.sql           ← Complete SQL: schema + seed data + all 7 queries
```

---

## 🗂️ Database Schema (ERD)

### Relationships

| Relationship Type      | Tables Involved    | Description                                              |
| ---------------------- | ------------------ | -------------------------------------------------------- |
| **One to Many**        | Users → Bookings   | One user can make many ticket bookings                   |
| **Many to One**        | Bookings → Matches | Many bookings can belong to one match                    |
| **Logical One to One** | Booking Row        | Each booking row maps exactly one user to one match seat |

### ERD Diagram

```
┌─────────────────────┐          ┌──────────────────────────┐          ┌──────────────────────┐
│        USERS        │          │         BOOKINGS         │          │       MATCHES        │
├─────────────────────┤          ├──────────────────────────┤          ├──────────────────────┤
│ PK  user_id         │ 1      ∞ │ PK  booking_id           │ ∞      1 │ PK  match_id         │
│     full_name       │──────────│ FK  user_id              │──────────│     fixture          │
│     email (UNIQUE)  │          │ FK  match_id             │          │     tournament_cat.  │
│     role            │          │     seat_number          │          │     base_ticket_price│
│     phone_number    │          │     payment_status       │          │     match_status     │
└─────────────────────┘          │     total_cost           │          └──────────────────────┘
                                 └──────────────────────────┘
```

> 📎 **Full ERD Link (Draw.io):** [https://drawsql.app/teams/sahidul-islam/diagrams/football-ticket-booking-system](#)

---

## 📐 Table Definitions

### 1. Users Table

Tracks all admin staff and customers registered on the platform.

| Field          | Data Type    | Constraints      | Description                            |
| -------------- | ------------ | ---------------- | -------------------------------------- |
| `user_id`      | SERIAL       | PRIMARY KEY      | Unique ID for each user                |
| `full_name`    | VARCHAR(100) | NOT NULL         | First and last name                    |
| `email`        | VARCHAR(150) | NOT NULL, UNIQUE | Login email address                    |
| `role`         | VARCHAR(50)  | NOT NULL, CHECK  | `'Ticket Manager'` or `'Football Fan'` |
| `phone_number` | VARCHAR(20)  | NULLABLE         | Contact mobile number                  |

### 2. Matches Table

Catalogs tournament fixtures with stadium logistics and ticket pricing.

| Field                 | Data Type     | Constraints         | Description                                                  |
| --------------------- | ------------- | ------------------- | ------------------------------------------------------------ |
| `match_id`            | SERIAL        | PRIMARY KEY         | Unique ID for each match                                     |
| `fixture`             | VARCHAR(200)  | NOT NULL            | Competing teams (e.g. _Real Madrid vs Barcelona_)            |
| `tournament_category` | VARCHAR(100)  | NOT NULL            | League or cup title                                          |
| `base_ticket_price`   | DECIMAL(10,2) | NOT NULL, CHECK ≥ 0 | Standard entry seat price                                    |
| `match_status`        | VARCHAR(50)   | NOT NULL, CHECK     | `'Available'`, `'Selling Fast'`, `'Sold Out'`, `'Postponed'` |

### 3. Bookings Table

Transactional table recording individual ticket purchases.

| Field            | Data Type     | Constraints            | Description                                             |
| ---------------- | ------------- | ---------------------- | ------------------------------------------------------- |
| `booking_id`     | SERIAL        | PRIMARY KEY            | Unique tracking number for each purchase                |
| `user_id`        | INT           | NOT NULL, FK → Users   | Links booking to the purchasing user                    |
| `match_id`       | INT           | NOT NULL, FK → Matches | Links booking to the specific match                     |
| `seat_number`    | VARCHAR(20)   | NULLABLE               | Allocated seat identifier (e.g. `A-12`)                 |
| `payment_status` | VARCHAR(50)   | NULLABLE, CHECK        | `'Pending'`, `'Confirmed'`, `'Cancelled'`, `'Refunded'` |
| `total_cost`     | DECIMAL(10,2) | NOT NULL, CHECK ≥ 0    | Final invoice price                                     |

---

## ⚙️ Setup & Installation

### Prerequisites

- PostgreSQL installed on your machine ([Download](https://www.postgresql.org/download/))
- `psql` command-line tool or a GUI like **pgAdmin** / **DBeaver**

### Steps

**1. Clone the repository**

```bash
git clone https://github.com/Sahidulislam05/Football-Ticket-Booking-System
cd Football-Ticket-Booking-System
```

**2. Open PostgreSQL and create a database**

```sql
CREATE DATABASE football_ticket_db;
\c football_ticket_db
```

**3. Run the SQL file**

```bash
psql -U postgres -d football_ticket_db -f QUERY.sql
```

Or paste the contents of `QUERY.sql` directly into **pgAdmin's Query Tool** and click ▶ Run.

**4. Verify tables were created**

```sql
\dt
```

You should see:

```
 Schema |   Name   | Type  |  Owner
--------+----------+-------+----------
 public | bookings | table | postgres
 public | matches  | table | postgres
 public | users    | table | postgres
```

---

## 🔍 SQL Queries (Part 2)

### Query 1 — Champions League Available Matches

> Retrieve all upcoming matches in the `Champions League` where status is `Available`.

**Concepts:** `WHERE`, `AND`

```sql
SELECT match_id, fixture, base_ticket_price
FROM Matches
WHERE tournament_category = 'Champions League'
  AND match_status = 'Available';
```

**Output:**

| match_id | fixture                  | base_ticket_price |
| -------- | ------------------------ | ----------------- |
| 101      | Real Madrid vs Barcelona | 150.00            |
| 103      | Bayern Munich vs PSG     | 130.00            |

---

### Query 2 — User Name Pattern Search

> Search users whose name starts with `'Tanvir'` OR contains `'Haque'` (case-insensitive).

**Concepts:** `ILIKE`, `OR`

```sql
SELECT user_id, full_name, email
FROM Users
WHERE full_name ILIKE 'Tanvir%'
   OR full_name ILIKE '%Haque%';
```

**Output:**

| user_id | full_name     | email           |
| ------- | ------------- | --------------- |
| 1       | Tanvir Rahman | tanvir@mail.com |
| 2       | Asif Haque    | asif@mail.com   |

---

### Query 3 — NULL Payment Status Handling

> Retrieve all bookings where `payment_status` is missing, replacing `NULL` with `'Action Required'`.

**Concepts:** `IS NULL`, `COALESCE`

```sql
SELECT
    booking_id,
    user_id,
    match_id,
    COALESCE(payment_status, 'Action Required') AS systematic_status
FROM Bookings
WHERE payment_status IS NULL;
```

**Output:**

| booking_id | user_id | match_id | systematic_status |
| ---------- | ------- | -------- | ----------------- |
| 504        | 2       | 101      | Action Required   |

---

### Query 4 — Booking Details with INNER JOIN

> Retrieve booking details along with the user's name and match fixture using `INNER JOIN`.

**Concepts:** `INNER JOIN` across three tables

```sql
SELECT
    b.booking_id,
    u.full_name,
    m.fixture,
    b.total_cost
FROM Bookings b
INNER JOIN Users   u ON b.user_id  = u.user_id
INNER JOIN Matches m ON b.match_id = m.match_id;
```

**Output:**

| booking_id | full_name     | fixture                  | total_cost |
| ---------- | ------------- | ------------------------ | ---------- |
| 501        | Tanvir Rahman | Real Madrid vs Barcelona | 150.00     |
| 502        | Tanvir Rahman | Man City vs Liverpool    | 120.00     |
| 503        | Asif Haque    | Real Madrid vs Barcelona | 150.00     |
| 504        | Asif Haque    | Real Madrid vs Barcelona | 150.00     |
| 505        | Sajjad Rahman | Man City vs Liverpool    | 120.00     |

---

### Query 5 — All Users Including Non-Bookers (LEFT JOIN)

> List all users and their bookings, including fans who have **never** bought a ticket.

**Concepts:** `LEFT JOIN`

```sql
SELECT
    u.user_id,
    u.full_name,
    b.booking_id
FROM Users u
LEFT JOIN Bookings b ON u.user_id = b.user_id;
```

**Output:**

| user_id | full_name     | booking_id |
| ------- | ------------- | ---------- |
| 1       | Tanvir Rahman | 501        |
| 1       | Tanvir Rahman | 502        |
| 2       | Asif Haque    | 503        |
| 2       | Asif Haque    | 504        |
| 3       | Sajjad Rahman | 505        |
| 4       | Jannat Ara    | NULL       |

---

### Query 6 — Bookings Above Average Cost (Subquery)

> Find all bookings where `total_cost` is **strictly higher** than the average cost of all bookings.
>
> 📊 \*Average = (150 + 120 + 150 + 150 + 120) / 5 = **138.00\***

**Concepts:** Subquery with `AVG()`

```sql
SELECT booking_id, match_id, total_cost
FROM Bookings
WHERE total_cost > (
    SELECT AVG(total_cost) FROM Bookings
);
```

**Output:**

| booking_id | match_id | total_cost |
| ---------- | -------- | ---------- |
| 501        | 101      | 150.00     |
| 503        | 101      | 150.00     |
| 504        | 101      | 150.00     |

---

### Query 7 — Top 2 Expensive Matches with Pagination

> Retrieve the top 2 most expensive matches **skipping** the single highest-priced match.

**Concepts:** `ORDER BY DESC`, `LIMIT`, `OFFSET`

```sql
SELECT match_id, fixture, base_ticket_price
FROM Matches
ORDER BY base_ticket_price DESC
LIMIT 2 OFFSET 1;
```

> `OFFSET 1` → Skips **Real Madrid vs Barcelona** (150.00) at rank #1

**Output:**

| match_id | fixture               | base_ticket_price |
| -------- | --------------------- | ----------------- |
| 103      | Bayern Munich vs PSG  | 130.00            |
| 102      | Man City vs Liverpool | 120.00            |

## 📊 Sample Data

### Users

| user_id | full_name     | email           | role           | phone_number   |
| ------- | ------------- | --------------- | -------------- | -------------- |
| 1       | Tanvir Rahman | tanvir@mail.com | Football Fan   | +8801711111111 |
| 2       | Asif Haque    | asif@mail.com   | Football Fan   | +8801722222222 |
| 3       | Sajjad Rahman | sajjad@mail.com | Ticket Manager | +8801733333333 |
| 4       | Jannat Ara    | jannat@mail.com | Football Fan   | NULL           |

### Matches

| match_id | fixture                  | tournament_category | base_ticket_price | match_status |
| -------- | ------------------------ | ------------------- | ----------------- | ------------ |
| 101      | Real Madrid vs Barcelona | Champions League    | 150.00            | Available    |
| 102      | Man City vs Liverpool    | Premier League      | 120.00            | Selling Fast |
| 103      | Bayern Munich vs PSG     | Champions League    | 130.00            | Available    |
| 104      | AC Milan vs Inter Milan  | Serie A             | 90.00             | Sold Out     |
| 105      | Juventus vs Roma         | Serie A             | 80.00             | Available    |

### Bookings

| booking_id | user_id | match_id | seat_number | payment_status | total_cost |
| ---------- | ------- | -------- | ----------- | -------------- | ---------- |
| 501        | 1       | 101      | A-12        | Confirmed      | 150.00     |
| 502        | 1       | 102      | B-04        | Confirmed      | 120.00     |
| 503        | 2       | 101      | A-13        | Confirmed      | 150.00     |
| 504        | 2       | 101      | NULL        | NULL           | 150.00     |
| 505        | 3       | 102      | C-20        | Pending        | 120.00     |

---

## 👤 Author

**Your Name Here**

- GitHub: [@Sahidulislam05](https://github.com/Sahidulislam05)
- Email: sahidulislamcst@gmail.com

---

## 📄 License

This project is submitted as an academic assignment. All work is original and completed independently in accordance with the course's academic integrity policy.
