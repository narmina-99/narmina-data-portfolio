/*
Project: SQL Practice (PostgreSQL)
Topic: Subqueries + Window Functions
Description:
Examples of ROW_NUMBER, DENSE_RANK, LAG, window SUM,
and subqueries in WHERE/FROM for analytical tasks.
*/

-- =========================================================
-- 01) ROW_NUMBER / LAG basics
-- =========================================================

-- 1.1 Add row numbers by price (cheapest -> most expensive)
SELECT
    p.*,
    ROW_NUMBER() OVER (ORDER BY p.price) AS rn_by_price
FROM product p;

-- 1.2 Price difference with previous product (ordered by product_id)
SELECT
    p.product_id,
    p.price,
    p.price - LAG(p.price) OVER (ORDER BY p.product_id) AS price_diff_from_prev
FROM product p;

-- =========================================================
-- 02) Lowest total spend customer (two ways)
-- =========================================================

-- 2.1 Using a subquery + DENSE_RANK (lowest total spend)
SELECT CONCAT(c.last_name, ' ', c.first_name) AS customer_full_name
FROM (
    SELECT
        o.customer_id,
        SUM(o.amount) AS total_amount,
        DENSE_RANK() OVER (ORDER BY SUM(o.amount) ASC) AS rnk
    FROM orders o
    GROUP BY o.customer_id
) t
JOIN customer c ON c.customer_id = t.customer_id
WHERE t.rnk = 1;

-- 2.2 Using subqueries in WHERE (lowest total spend)
SELECT CONCAT(c.last_name, ' ', c.first_name) AS customer_full_name
FROM customer c
WHERE c.customer_id IN (
    SELECT o.customer_id
    FROM orders o
    GROUP BY o.customer_id
    HAVING SUM(o.amount) = (
        SELECT SUM(o2.amount) AS min_total
        FROM orders o2
        GROUP BY o2.customer_id
        ORDER BY min_total ASC
        LIMIT 1
    )
);

-- =========================================================
-- 03) Subquery in FROM + LEFT JOIN
-- =========================================================

-- 3.1 Total quantity (or amount) per product from order_product_list
-- NOTE: This shows ALL products, even if never ordered (LEFT JOIN).
SELECT
    p.product,
    opl.total_amount
FROM product p
LEFT JOIN (
    SELECT
        product_id,
        SUM(amount) AS total_amount
    FROM order_product_list
    GROUP BY product_id
) opl ON opl.product_id = p.product_id;

-- =========================================================
-- 04) Window SUM (cumulative)
-- =========================================================

-- 4.1 Cumulative spend per customer by order sequence
SELECT
    o.order_id,
    o.customer_id,
    o.amount,
    SUM(o.amount) OVER (
        PARTITION BY o.customer_id
        ORDER BY o.order_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM orders o;

-- =========================================================
-- 05) N-th order per customer (ROW_NUMBER with PARTITION)
-- =========================================================

-- 5.1 Show 5th order for each customer (if exists)
SELECT *
FROM (
    SELECT
        o.*,
        ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_id) AS rn
    FROM orders o
) t
WHERE t.rn = 5;

-- =========================================================
-- 06) Average metric per customer using nested aggregation
-- =========================================================

-- 6.1 Average (per customer) of the average line amount per order
-- Step 1: compute avg(amount) within each order (order_product_list)
-- Step 2: average those order averages per customer
SELECT
    o.customer_id,
    AVG(opl.order_avg_amount) AS avg_order_line_amount_per_customer
FROM orders o
JOIN (
    SELECT
        order_id,
        AVG(amount) AS order_avg_amount
    FROM order_product_list
    GROUP BY order_id
) opl ON opl.order_id = o.order_id
GROUP BY o.customer_id
ORDER BY o.customer_id;

-- =========================================================
-- 07) Category share of total products (subquery in SELECT)
-- =========================================================

-- 7.1 Category with the highest share of products (percent of all products)
SELECT
    c.category,
    COUNT(p.product_id) * 100.0 / (SELECT COUNT(*) FROM product) AS percent_share
FROM category c
JOIN product p ON p.category_id = c.category_id
GROUP BY c.category
ORDER BY percent_share DESC
LIMIT 1;

-- 7.2 Maximum share value only (rounded)
SELECT ROUND(MAX(t.percent_share), 3) AS max_percent_share
FROM (
    SELECT
        p.category_id,
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM product) AS percent_share
    FROM product p
    GROUP BY p.category_id
) t;

-- =========================================================
-- 08) Top category by total sales (DENSE_RANK)
-- =========================================================

-- 8.1 Category with the maximum total order amount (by orders joined to categories)
SELECT category, total_sum
FROM (
    SELECT
        c.category,
        SUM(o.amount) AS total_sum,
        DENSE_RANK() OVER (ORDER BY SUM(o.amount) DESC) AS rnk
    FROM orders o
    JOIN order_product_list opl ON opl.order_id = o.order_id
    JOIN product p ON p.product_id = opl.product_id
    JOIN category c ON c.category_id = p.category_id
    GROUP BY c.category
) t
WHERE t.rnk = 1;

-- =========================================================
-- 09) LAG-based comparisons
-- =========================================================

-- 9.1 Orders where amount is exactly 25% higher than previous order amount (same customer)
SELECT *
FROM (
    SELECT
        o.*,
        LAG(o.amount) OVER (PARTITION BY o.customer_id ORDER BY o.order_id) AS prev_amount
    FROM orders o
) t
WHERE t.prev_amount IS NOT NULL
  AND t.amount = t.prev_amount * 1.25;

-- 9.2 Same task, but also compute percentage difference
SELECT *
FROM (
    SELECT
        o.order_id,
        o.customer_id,
        o.amount,
        LAG(o.amount) OVER (PARTITION BY o.customer_id ORDER BY o.order_id) AS prev_amount,
        (o.amount * 100.0 / LAG(o.amount) OVER (PARTITION BY o.customer_id ORDER BY o.order_id)) - 100 AS diff_percent
    FROM orders o
) t
WHERE t.prev_amount IS NOT NULL
  AND t.diff_percent = 25;

-- =========================================================
-- 10) Top category by revenue proxy (quantity * price)
-- =========================================================

-- 10.1 Category with maximum revenue proxy = SUM(quantity * price)
SELECT c.category
FROM category c
WHERE c.category_id IN (
    SELECT t.category_id
    FROM (
        SELECT
            p.category_id,
            SUM(opl.amount * p.price) AS revenue_proxy,
            DENSE_RANK() OVER (ORDER BY SUM(opl.amount * p.price) DESC) AS rnk
        FROM order_product_list opl
        JOIN product p ON p.product_id = opl.product_id
        GROUP BY p.category_id
    ) t
    WHERE t.rnk = 1
);