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