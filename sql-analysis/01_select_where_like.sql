/*
Project: SQL Practice (PostgreSQL)
Topic: SELECT / WHERE / LIKE / ILIKE / DISTINCT / functions
Description: Basic queries for filtering, text search, date and numeric operations.
*/

-- =========================================================
-- 01) Basic SELECT
-- =========================================================

-- 1.1 View all staff
SELECT *
FROM staff;

-- 1.2 Select specific columns
SELECT first_name, last_name
FROM staff;

-- =========================================================
-- 02) Filtering (WHERE) + ILIKE
-- =========================================================

-- 2.1 Names that start with 'a' and end with 'a' (case-insensitive)
SELECT first_name, last_name
FROM staff
WHERE first_name ILIKE 'a%a';

-- =========================================================
-- 03) DISTINCT + date functions
-- =========================================================

-- 3.1 Unique years of order creation
SELECT DISTINCT EXTRACT(YEAR FROM created_date) AS order_year
FROM orders
ORDER BY order_year;

-- 3.2 Convert timestamp to date
SELECT created_date::date AS created_day
FROM orders;

-- =========================================================
-- 04) Numeric calculations
-- =========================================================

-- 4.1 Calculate net amount (example: removing 20% tax/VAT)
SELECT
  order_id,
  amount,
  ROUND(amount / 1.2, 2) AS amount_net
FROM orders;

-- 4.2 Apply discount to amount (cast to numeric to avoid integer truncation)
SELECT
  order_id,
  amount,
  discount,
  amount * ((100 - discount)::numeric / 100) AS amount_after_discount
FROM orders;

-- =========================================================
-- 05) LIKE patterns + text rules
-- =========================================================

-- 5.1 Cities where the 3rd character is 'z' (2 underscores = any two chars)
SELECT city
FROM city
WHERE city LIKE '__z%';

-- 5.2 Products that contain a space in the name
SELECT *
FROM product
WHERE product LIKE '% %';

-- 5.3 Products with price >= 100 and product name length = 10
SELECT *
FROM product
WHERE price >= 100
  AND char_length(product) = 10;

-- =========================================================
-- 06) Text comparisons
-- =========================================================

-- 6.1 Customers where first_name and last_name have same length
--     and start with the same first letter
SELECT *
FROM customer
WHERE char_length(first_name) = char_length(last_name)
  AND left(first_name, 1) = left(last_name, 1);

-- 6.2 Count cities where first letter equals last letter
SELECT COUNT(*) AS cities_first_last_same
FROM city
WHERE left(city, 1) = right(city, 1);

-- =========================================================
-- 07) Aggregations + conditions
-- =========================================================

-- 7.1 Count deleted products
SELECT COUNT(*) AS deleted_products
FROM product
WHERE deleted = true;

-- 7.2 Count orders with amount between 200 and 215
SELECT COUNT(*) AS orders_200_215
FROM orders
WHERE amount BETWEEN 200 AND 215;

-- 7.3 Show discounts greater than 3
SELECT discount
FROM orders
WHERE discount > 3;