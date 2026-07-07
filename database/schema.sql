-- =====================================================================
--  Full Stack Intern Project v2 - Database Schema
--  Target: MySQL 8.x   (create / manage with HeidiSQL)
--
--  A basic e-commerce system that manages store invoices.
--  The store has customers, items and invoices. Each customer can
--  purchase multiple items per invoice.
--
--  Run this whole file once to (re)create the database from scratch.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Schema (database)
-- ---------------------------------------------------------------------
DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE ecommerce_db;

-- ---------------------------------------------------------------------
-- Table: customers
--   A person who can buy items from the store.
-- ---------------------------------------------------------------------
CREATE TABLE customers (
    id          BIGINT       NOT NULL AUTO_INCREMENT,
    name        VARCHAR(150) NOT NULL,
    email       VARCHAR(150) DEFAULT NULL,
    phone       VARCHAR(30)  DEFAULT NULL,
    address     VARCHAR(255) DEFAULT NULL,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_customers_email (email),
    KEY idx_customers_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Table: items
--   A product that the store sells.
-- ---------------------------------------------------------------------
CREATE TABLE items (
    id              BIGINT        NOT NULL AUTO_INCREMENT,
    name            VARCHAR(150)  NOT NULL,
    description     VARCHAR(500)  DEFAULT NULL,
    price           DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    stock_quantity  INT           NOT NULL DEFAULT 0,
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_items_name (name),
    CONSTRAINT chk_items_price CHECK (price >= 0),
    CONSTRAINT chk_items_stock CHECK (stock_quantity >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Table: invoices
--   A single purchase made by one customer. The header row.
--   total_amount is the sum of all of its invoice_items line totals.
-- ---------------------------------------------------------------------
CREATE TABLE invoices (
    id            BIGINT         NOT NULL AUTO_INCREMENT,
    customer_id   BIGINT         NOT NULL,
    invoice_date  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount  DECIMAL(12,2)  NOT NULL DEFAULT 0.00,
    status        VARCHAR(20)    NOT NULL DEFAULT 'CREATED',
    created_at    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_invoices_customer (customer_id),
    KEY idx_invoices_date (invoice_date),
    CONSTRAINT fk_invoices_customer
        FOREIGN KEY (customer_id) REFERENCES customers (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Table: invoice_items  (line items)
--   Resolves the many-to-many relationship between invoices and items
--   and stores, per line: the quantity purchased, the unit price at the
--   time of sale (a snapshot, so later item price changes do not alter
--   historical invoices) and the computed line total.
-- ---------------------------------------------------------------------
CREATE TABLE invoice_items (
    id          BIGINT         NOT NULL AUTO_INCREMENT,
    invoice_id  BIGINT         NOT NULL,
    item_id     BIGINT         NOT NULL,
    quantity    INT            NOT NULL,
    unit_price  DECIMAL(10,2)  NOT NULL,
    line_total  DECIMAL(12,2)  NOT NULL,
    PRIMARY KEY (id),
    KEY idx_invoice_items_invoice (invoice_id),
    KEY idx_invoice_items_item (item_id),
    CONSTRAINT fk_invoice_items_invoice
        FOREIGN KEY (invoice_id) REFERENCES invoices (id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_invoice_items_item
        FOREIGN KEY (item_id) REFERENCES items (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_invoice_items_qty CHECK (quantity > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
