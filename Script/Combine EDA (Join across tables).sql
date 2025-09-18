

-- ============================================
-- Task 1: Which products are sold the most (by quantity)?
-- ============================================
    WITH CTE_JOIN AS (
        SELECT 
            p.product_name, -- product name
            s.quantity      -- quantity sold
        FROM gold.fact_sales AS s
        LEFT JOIN gold.dim_products AS p
        ON s.product_key = p.product_key
    ),
    CTE_aggregation AS (
        SELECT
            product_name,
            SUM(quantity) AS total_quantity_sold -- total quantity per product
        FROM CTE_JOIN
        GROUP BY product_name
    ),
    CTE_rank AS (
        SELECT
            product_name,
            total_quantity_sold,
            RANK() OVER(ORDER BY total_quantity_sold DESC) AS rank_list -- rank products by quantity sold
        FROM CTE_aggregation
    )
    SELECT *
    FROM CTE_rank
    WHERE rank_list = 1; -- top-selling product(s)

-- ============================================
-- Task 2: Which countries contribute the highest total revenue? 
-- ============================================
    WITH CTE_join AS (
        SELECT c.country, s.sales
        FROM gold.fact_sales AS s
        LEFT JOIN gold.dim_customers AS c
        ON s.customer_key = c.customer_key
    ),
    CTE_aggregation AS (
        SELECT country, SUM(sales) AS total_revenue -- total revenue per country
        FROM CTE_join
        GROUP BY country
    )
    SELECT TOP 1 *
    FROM CTE_aggregation
    ORDER BY total_revenue DESC;

-- ============================================
-- Task 3: What is the average order value per customer? 
-- ============================================
    WITH CTE_JOIN AS (
        SELECT 
            c.customer_id, -- unique customer ID
            CONCAT(c.firstname, ' ', c.lastname) AS customer_name, -- customer full name
            s.sales,       -- sales amount
            s.order_number -- order number
        FROM gold.fact_sales AS s
        LEFT JOIN gold.dim_customers AS c
        ON s.customer_key = c.customer_key
    ),
    CTE_aggregation AS (
        SELECT 
            customer_id,
            customer_name,
            SUM(sales) AS total_sales,                     -- total sales per customer
            COUNT(DISTINCT order_number) AS total_order,   -- total orders per customer
            SUM(sales)/COUNT(DISTINCT order_number) AS avg_order_value -- average order value
        FROM CTE_JOIN
        GROUP BY customer_id, customer_name
    )
    SELECT *
    FROM CTE_aggregation
    ORDER BY avg_order_value DESC;

-- ============================================
-- Task 4:Which categories are most popular among male vs female customers? 
-- ============================================
    WITH CTE_JOIN AS (
        SELECT
            c.gender, -- customer gender
            s.sales   -- sales amount
        FROM gold.fact_sales AS s
        LEFT JOIN gold.dim_customers AS c
        ON s.customer_key = c.customer_key
    ),
    CTE_aggregation AS (
        SELECT
            gender,
            SUM(sales) AS total_revenue -- total revenue per gender
        FROM CTE_JOIN
        GROUP BY gender
        HAVING gender != 'n/a' -- exclude unknown gender
    )
    SELECT *
    FROM CTE_aggregation
    ORDER BY total_revenue DESC;