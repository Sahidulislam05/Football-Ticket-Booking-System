-- =========================================================================
-- SYSTEM: Football Ticket Booking System Database Setup
-- DESCRIPTION: Complete DDL (Table Creation) + DML (Data Seeding) + Queries
-- DATABASE: PostgreSQL
-- =========================================================================
-- =========================================================================
-- DROP TABLES IF THEY ALREADY EXIST TO PREVENT CONFLICTS
-- (Bookings must be dropped first because it has FK references)
-- =========================================================================
DROP TABLE IF EXISTS Bookings;

DROP TABLE IF EXISTS Matches;

DROP TABLE IF EXISTS Users;

-- =========================================================================
-- 1. CREATE USERS TABLE
-- =========================================================================
CREATE TABLE
    Users (
        user_id SERIAL,
        full_name VARCHAR(100) NOT NULL,
        email VARCHAR(150) NOT NULL,
        role VARCHAR(50) NOT NULL,
        phone_number VARCHAR(20),
        -- PK: every user must have a unique ID
        PRIMARY KEY (user_id),
        -- UNIQUE: no two users can share the same email
        UNIQUE (email),
        -- CHECK: role must be one of the two allowed values
        CHECK (role IN ('Ticket Manager', 'Football Fan'))
    );

-- =========================================================================
-- 2. CREATE MATCHES TABLE
-- =========================================================================
CREATE TABLE
    Matches (
        match_id SERIAL,
        fixture VARCHAR(200) NOT NULL,
        tournament_category VARCHAR(100) NOT NULL,
        base_ticket_price DECIMAL(10, 2) NOT NULL,
        match_status VARCHAR(50) NOT NULL,
        -- PK: every match must have a unique ID
        PRIMARY KEY (match_id),
        -- CHECK: ticket price cannot be negative
        CHECK (base_ticket_price >= 0),
        -- CHECK: status must be one of the four allowed values
        CHECK (
            match_status IN (
                'Available',
                'Selling Fast',
                'Sold Out',
                'Postponed'
            )
        )
    );

-- =========================================================================
-- 3. CREATE BOOKINGS TABLE
-- =========================================================================
CREATE TABLE
    Bookings (
        booking_id SERIAL,
        user_id INT NOT NULL,
        match_id INT NOT NULL,
        seat_number VARCHAR(20), -- nullable (can be NULL as per sample data)
        payment_status VARCHAR(50), -- nullable (can be NULL as per sample data)
        total_cost DECIMAL(10, 2) NOT NULL,
        -- PK: every booking must have a unique tracking number
        PRIMARY KEY (booking_id),
        -- FK: user_id must reference a valid user in the Users table
        FOREIGN KEY (user_id) REFERENCES Users (user_id) ON DELETE CASCADE,
        -- FK: match_id must reference a valid match in the Matches table
        FOREIGN KEY (match_id) REFERENCES Matches (match_id) ON DELETE CASCADE,
        -- CHECK: total cost must be zero or positive
        CHECK (total_cost >= 0),
        -- CHECK: payment status restricted to four valid states
        CHECK (
            payment_status IN ('Pending', 'Confirmed', 'Cancelled', 'Refunded')
        )
    );

-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO USERS
-- =========================================================================
INSERT INTO
    Users (user_id, full_name, email, role, phone_number)
VALUES
    (
        1,
        'Tanvir Rahman',
        'tanvir@mail.com',
        'Football Fan',
        '+8801711111111'
    ),
    (
        2,
        'Asif Haque',
        'asif@mail.com',
        'Football Fan',
        '+8801722222222'
    ),
    (
        3,
        'Sajjad Rahman',
        'sajjad@mail.com',
        'Ticket Manager',
        '+8801733333333'
    ),
    (
        4,
        'Jannat Ara',
        'jannat@mail.com',
        'Football Fan',
        NULL
    );

-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO MATCHES
-- =========================================================================
INSERT INTO
    Matches (
        match_id,
        fixture,
        tournament_category,
        base_ticket_price,
        match_status
    )
VALUES
    (
        101,
        'Real Madrid vs Barcelona',
        'Champions League',
        150.00,
        'Available'
    ),
    (
        102,
        'Man City vs Liverpool',
        'Premier League',
        120.00,
        'Selling Fast'
    ),
    (
        103,
        'Bayern Munich vs PSG',
        'Champions League',
        130.00,
        'Available'
    ),
    (
        104,
        'AC Milan vs Inter Milan',
        'Serie A',
        90.00,
        'Sold Out'
    ),
    (
        105,
        'Juventus vs Roma',
        'Serie A',
        80.00,
        'Available'
    );

-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO BOOKINGS
-- =========================================================================
INSERT INTO
    Bookings (
        booking_id,
        user_id,
        match_id,
        seat_number,
        payment_status,
        total_cost
    )
VALUES
    (501, 1, 101, 'A-12', 'Confirmed', 150.00),
    (502, 1, 102, 'B-04', 'Confirmed', 120.00),
    (503, 2, 101, 'A-13', 'Confirmed', 150.00),
    (504, 2, 101, NULL, NULL, 150.00),
    (505, 3, 102, 'C-20', 'Pending', 120.00);

-- =========================================================================
-- PART 2: SQL QUERIES
-- =========================================================================
-- -------------------------------------------------------------------------
-- Query 1: Retrieve all Champions League matches where status is 'Available'
-- Concepts used: WHERE with AND condition
-- -------------------------------------------------------------------------
SELECT
    match_id,
    fixture,
    base_ticket_price
FROM
    Matches
WHERE
    tournament_category = 'Champions League'
    AND match_status = 'Available';

/*
Expected Output:
match_id | fixture                  | base_ticket_price
----------+--------------------------+-------------------
101 | Real Madrid vs Barcelona |            150.00
103 | Bayern Munich vs PSG     |            130.00
 */
-- -------------------------------------------------------------------------
-- Query 2: Search users whose name starts with 'Tanvir' OR contains 'Haque'
-- Concepts used: ILIKE (case-insensitive pattern matching)
-- -------------------------------------------------------------------------
SELECT
    user_id,
    full_name,
    email
FROM
    Users
WHERE
    full_name ILIKE 'Tanvir%'
    OR full_name ILIKE '%Haque%';

/*
Expected Output:
user_id | full_name     | email
---------+---------------+------------------
1 | Tanvir Rahman | tanvir@mail.com
2 | Asif Haque    | asif@mail.com
 */
-- -------------------------------------------------------------------------
-- Query 3: Bookings where payment_status is NULL → show 'Action Required'
-- Concepts used: IS NULL, COALESCE
-- -------------------------------------------------------------------------
SELECT
    booking_id,
    user_id,
    match_id,
    COALESCE(payment_status, 'Action Required') AS systematic_status
FROM
    Bookings
WHERE
    payment_status IS NULL;

/*
Expected Output:
booking_id | user_id | match_id | systematic_status
------------+---------+----------+-------------------
504 |       2 |      101 | Action Required
 */
-- -------------------------------------------------------------------------
-- Query 4: Booking details with user's full name and match fixture
-- Concepts used: INNER JOIN (joins only matching rows from both sides)
-- -------------------------------------------------------------------------
SELECT
    b.booking_id,
    u.full_name,
    m.fixture,
    b.total_cost
FROM
    Bookings b
    INNER JOIN Users u ON b.user_id = u.user_id
    INNER JOIN Matches m ON b.match_id = m.match_id;

/*
Expected Output:
booking_id | full_name     | fixture                  | total_cost
------------+---------------+--------------------------+------------
501 | Tanvir Rahman | Real Madrid vs Barcelona |     150.00
502 | Tanvir Rahman | Man City vs Liverpool     |     120.00
503 | Asif Haque    | Real Madrid vs Barcelona |     150.00
504 | Asif Haque    | Real Madrid vs Barcelona |     150.00
505 | Sajjad Rahman | Man City vs Liverpool     |     120.00
 */
-- -------------------------------------------------------------------------
-- Query 5: All users and their booking IDs (including fans with NO bookings)
-- Concepts used: LEFT JOIN (keeps ALL rows from the left/Users table)
-- -------------------------------------------------------------------------
SELECT
    u.user_id,
    u.full_name,
    b.booking_id
FROM
    Users u
    LEFT JOIN Bookings b ON u.user_id = b.user_id;

/*
Expected Output:
user_id | full_name     | booking_id
---------+---------------+------------
1 | Tanvir Rahman |        501
1 | Tanvir Rahman |        502
2 | Asif Haque    |        503
2 | Asif Haque    |        504
3 | Sajjad Rahman |        505
4 | Jannat Ara    |       NULL   ← no booking, but still listed
 */
-- -------------------------------------------------------------------------
-- Query 6: Bookings where total_cost is higher than the average cost
-- Concepts used: Subquery with AVG()
-- Average = (150+120+150+150+120) / 5 = 138.00
-- So bookings > 138 → booking IDs 501, 503, 504 (all 150.00)
-- -------------------------------------------------------------------------
SELECT
    booking_id,
    match_id,
    total_cost
FROM
    Bookings
WHERE
    total_cost > (
        SELECT
            AVG(total_cost)
        FROM
            Bookings
    );

/*
Expected Output:
booking_id | match_id | total_cost
------------+----------+------------
501 |      101 |     150.00
503 |      101 |     150.00
504 |      101 |     150.00
 */
-- -------------------------------------------------------------------------
-- Query 7: Top 2 most expensive matches, skipping the absolute highest
-- Concepts used: ORDER BY DESC, LIMIT, OFFSET
-- OFFSET 1 → skips Real Madrid vs Barcelona (150) which is rank #1
-- -------------------------------------------------------------------------
SELECT
    match_id,
    fixture,
    base_ticket_price
FROM
    Matches
ORDER BY
    base_ticket_price DESC
LIMIT
    2
OFFSET
    1;

/*
Expected Output (skips Real Madrid vs Barcelona at 150):
match_id | fixture              | base_ticket_price
----------+----------------------+-------------------
103 | Bayern Munich vs PSG |            130.00
102 | Man City vs Liverpool|            120.00
 */