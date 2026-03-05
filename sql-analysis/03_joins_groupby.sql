/*
Project: SQL Practice (PostgreSQL)
Topic: JOINs, GROUP BY, HAVING, Aggregations
Description:
Combining multiple tables to analyze customers, cities,
categories and sales performance.
*/

-- =========================================================
-- 01) Basic JOINs
-- =========================================================

-- 1.1 Customer full name + address
SELECT
    c.first_name AS "Имя",
    c.last_name  AS "Фамилия",
    a.address
FROM customer c
JOIN address a ON a.address_id = c.address_id;

-- 1.2 Customer + address + city
SELECT
    c.first_name AS "Имя",
    c.last_name  AS "Фамилия",
    a.address,
    ci.city
FROM customer c
JOIN address a ON a.address_id = c.address_id
JOIN city ci ON a.city_id = ci.city_id;

-- =========================================================
-- 02) Filtering with JOIN
-- =========================================================

-- 2.1 Customers living in 'Aden'
SELECT
    c.first_name,
    c.last_name
FROM customer c
JOIN address a ON a.address_id = c.address_id
JOIN city ci ON ci.city_id = a.city_id
WHERE ci.city = 'Aden';

-- 2.2 Count staff in unit 'Группа развития розничных продаж'
SELECT COUNT(*) AS staff_in_unit
FROM staff s
JOIN "structure" st ON s.unit_id = st.unit_id
WHERE st.unit = 'Группа развития розничных продаж';

-- =========================================================
-- 03) Aggregations (COUNT / AVG / MAX)
-- =========================================================

-- 3.1 Count products in category 'Музыка'
SELECT COUNT(*) AS music_products
FROM category c
JOIN product p ON c.category_id = p.category_id
WHERE c.category = 'Музыка';

-- 3.2 Average order amount for customers whose last name starts with 'a'
SELECT AVG(o.amount) AS avg_order_amount
FROM customer c
JOIN orders o ON o.customer_id = c.customer_id
WHERE c.last_name ILIKE 'a%';

-- 3.3 Maximum product price in range (0, 50)
SELECT MAX(price) AS max_price_under_50
FROM product
WHERE price > 0 AND price < 50;

-- 3.4 Total number of orders
SELECT COUNT(order_id) AS total_orders
FROM orders;

-- =========================================================
-- 04) GROUP BY + HAVING
-- =========================================================

-- 4.1 Categories with more than 30 products
SELECT
    c.category,
    COUNT(*) AS products_count
FROM category c
JOIN product p ON c.category_id = p.category_id
GROUP BY c.category
HAVING COUNT(*) > 30
ORDER BY products_count DESC;

-- =========================================================
-- 05) Business-Oriented Questions
-- =========================================================

-- 5.1 Number of orders made by customers living in 'El Alto'
SELECT COUNT(o.order_id) AS orders_in_el_alto
FROM customer c
JOIN orders o ON c.customer_id = o.customer_id
JOIN address a ON a.address_id = c.address_id
JOIN city ci ON ci.city_id = a.city_id
WHERE ci.city = 'El Alto';

-- 5.2 Number of orders for customer Linda Williams
SELECT
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS orders_count
FROM customer c
JOIN orders o ON c.customer_id = o.customer_id
WHERE c.first_name = 'Linda'
  AND c.last_name = 'Williams'
GROUP BY c.first_name, c.last_name;

-- 5.3 Number of UNIQUE customers who purchased products from category 'Игрушки'
SELECT COUNT(DISTINCT o.customer_id) AS unique_customers_toys
FROM orders o
JOIN order_product_list op ON o.order_id = op.order_id
JOIN product p ON op.product_id = p.product_id
JOIN category c ON p.category_id = c.category_id
WHERE c.category = 'Игрушки';