-- =====================================================================
--  Full Stack Intern Project v2 - Sample / Seed Data
--  Run AFTER schema.sql to populate the database with demo rows so the
--  API and frontend have something to show immediately.
-- =====================================================================
USE ecommerce_db;

-- ---------------------------------------------------------------------
-- Customers
-- ---------------------------------------------------------------------
INSERT INTO customers (name, email, phone, address) VALUES
    ('Alice Johnson',  'alice.johnson@example.com',  '+1-202-555-0101', '12 Maple Street, Springfield'),
    ('Bob Smith',      'bob.smith@example.com',      '+1-202-555-0102', '48 Oak Avenue, Rivertown'),
    ('Carol Martinez', 'carol.martinez@example.com', '+1-202-555-0103', '7 Pine Road, Lakeside'),
    ('David Lee',      'david.lee@example.com',       '+1-202-555-0104', '99 Cedar Lane, Hillview'),
    ('Emma Brown',     'emma.brown@example.com',      '+1-202-555-0105', '25 Birch Blvd, Downtown');

-- ---------------------------------------------------------------------
-- Items
-- ---------------------------------------------------------------------
INSERT INTO items (name, description, price, stock_quantity) VALUES
    ('Wireless Mouse',      'Ergonomic 2.4GHz wireless mouse',        19.99, 150),
    ('Mechanical Keyboard', 'RGB backlit mechanical keyboard',        79.99, 80),
    ('USB-C Cable',         '1m braided USB-C to USB-C cable',         9.49, 500),
    ('27" Monitor',         '4K UHD IPS display, 60Hz',              299.00, 40),
    ('Laptop Stand',        'Aluminium adjustable laptop stand',      34.95, 120),
    ('Webcam 1080p',        'Full HD webcam with built-in mic',       49.90, 60),
    ('Noise Cancel Headset','Over-ear Bluetooth noise cancelling',   129.99, 35),
    ('Desk Lamp',           'LED desk lamp with adjustable warmth',   22.50, 200);

-- ---------------------------------------------------------------------
-- Invoices + line items
--   total_amount below is the sum of the related line_total values.
-- ---------------------------------------------------------------------

-- Invoice 1 : Alice buys a mouse + keyboard
INSERT INTO invoices (customer_id, invoice_date, total_amount, status)
    VALUES (1, '2026-06-01 10:15:00', 99.98, 'CREATED');
INSERT INTO invoice_items (invoice_id, item_id, quantity, unit_price, line_total) VALUES
    (1, 1, 1, 19.99, 19.99),
    (1, 2, 1, 79.99, 79.99);

-- Invoice 2 : Bob buys a monitor + 2 USB-C cables
INSERT INTO invoices (customer_id, invoice_date, total_amount, status)
    VALUES (2, '2026-06-03 14:40:00', 317.98, 'CREATED');
INSERT INTO invoice_items (invoice_id, item_id, quantity, unit_price, line_total) VALUES
    (2, 4, 1, 299.00, 299.00),
    (2, 3, 2, 9.49, 18.98);

-- Invoice 3 : Alice buys a laptop stand + desk lamp
INSERT INTO invoices (customer_id, invoice_date, total_amount, status)
    VALUES (1, '2026-06-10 09:05:00', 57.45, 'CREATED');
INSERT INTO invoice_items (invoice_id, item_id, quantity, unit_price, line_total) VALUES
    (3, 5, 1, 34.95, 34.95),
    (3, 8, 1, 22.50, 22.50);

-- Invoice 4 : Carol buys a headset + webcam
INSERT INTO invoices (customer_id, invoice_date, total_amount, status)
    VALUES (3, '2026-06-15 16:20:00', 179.89, 'CREATED');
INSERT INTO invoice_items (invoice_id, item_id, quantity, unit_price, line_total) VALUES
    (4, 7, 1, 129.99, 129.99),
    (4, 6, 1, 49.90, 49.90);
