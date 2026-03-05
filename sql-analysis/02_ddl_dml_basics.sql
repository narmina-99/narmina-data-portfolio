/*
Project: SQL Practice (PostgreSQL)
Topic: DDL (CREATE / ALTER) + DML (INSERT / UPDATE)
Description:
Creation of delivery table, adding foreign key,
inserting records and updating related orders.
*/

-- =========================================================
-- 01) CREATE TABLE (DDL)
-- =========================================================

CREATE TABLE delivery (
    delivery_id serial PRIMARY KEY,
    address_id int REFERENCES address(address_id) NOT NULL,
    delivery_date date NOT NULL,
    time_range text[] NOT NULL,
    staff_id int REFERENCES staff(staff_id) NOT NULL,
    status del_status NOT NULL DEFAULT 'в обработке',
    last_update timestamp,
    create_date timestamp DEFAULT now(),
    deleted boolean NOT NULL DEFAULT false
);

-- Check table structure
SELECT * FROM delivery;

-- =========================================================
-- 02) ALTER TABLE — add foreign key to orders
-- =========================================================

ALTER TABLE orders
ADD CONSTRAINT orders_delivery_fkey
FOREIGN KEY (delivery_id)
REFERENCES delivery(delivery_id);

-- =========================================================
-- 03) INSERT (DML)
-- =========================================================

INSERT INTO delivery (address_id, delivery_date, time_range, staff_id)
VALUES
    (102, '2025-01-12', ARRAY['10:00:00', '18:00:00'], 2),
    (54,  '2025-01-12', ARRAY['10:00:00', '18:00:00'], 2),
    (22,  '2025-01-12', ARRAY['10:00:00', '18:00:00'], 2),
    (12,  '2025-01-12', ARRAY['10:00:00', '18:00:00'], 2);

-- =========================================================
-- 04) UPDATE (DML)
-- =========================================================

-- Assign deliveries to orders

UPDATE orders
SET delivery_id = 1
WHERE order_id = 1;

UPDATE orders
SET delivery_id = 2
WHERE order_id = 2;

UPDATE orders
SET delivery_id = 3
WHERE order_id = 3;

UPDATE orders
SET delivery_id = 4
WHERE order_id = 4;

-- Verify updates
SELECT * FROM orders;