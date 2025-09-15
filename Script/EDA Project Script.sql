

-- ============================================
-- Task 1: How many unique customers are in the dataset?
-- ============================================
    SELECT
        COUNT(DISTINCT customer_key) AS totalcustomer -- total unique customers
    FROM gold.dim_customers;

-- ============================================
-- Task 2: How many unique products are listed? 
-- ============================================
    SELECT
        COUNT(DISTINCT product_name) AS totalnumber_of_products -- total unique products
    FROM gold.dim_products;

-- ============================================
-- Task 3: How many total sales transactions are recorded? 
-- ============================================
    SELECT
        COUNT(sales) AS total_number_transaction -- total number of sales records
    FROM gold.fact_sales;

-- ============================================
-- Task 4: What is the distribution of customers by country? 
-- ============================================
    SELECT
        country,                 -- customer country
        COUNT(customer_key) AS Totalcustomer -- total customers per country
    FROM gold.dim_customers
    GROUP BY country
    ORDER BY Totalcustomer DESC;

-- ============================================
-- Task 5: How many categories and subcategories exist, and how many products fall into each?
-- ============================================
    SELECT
        category,                -- product category
        subcategory,             -- product subcategory
        COUNT(product_key) AS totalproducts -- total products in each category/subcategory
    FROM gold.dim_products
    GROUP BY category, subcategory
    ORDER BY category;

-- ============================================
-- Task 6: What is the earliest and latest order_date? 
-- ============================================
    SELECT
        MAX(order_date) AS latest_order, -- most recent order date
        MIN(order_date) AS earliest_order -- earliest order date
    FROM gold.fact_sales;

-- ============================================
-- Task 7: What percentage of customers are male vs female?
-- ============================================
    SELECT
        gender,                                  -- customer gender
        COUNT(customer_key) AS Totalcustomer,    -- number of customers per gender
        COUNT(customer_key)*100.0/SUM(COUNT(customer_key)) OVER() AS percent_value -- percentage per gender
    FROM gold.dim_customers
    GROUP BY gender;

-- ============================================
-- Task 8: Which products have the highest and lowest price? 
-- ============================================
    SELECT
        p.product_id,  -- product identifier
        s.price        -- sales price
    FROM gold.fact_sales AS s
    LEFT JOIN gold.dim_products AS p
    ON s.product_key = p.product_key
    WHERE price = (SELECT MAX(price) FROM gold.fact_sales) -- highest price
       OR price = (SELECT MIN(price) FROM gold.fact_sales) -- lowest price
    GROUP BY p.product_id, s.price
    ORDER BY price;

-- ============================================
-- Task 9: What is the distribution of order_date vs shipping_date (average shipping delay)? 
-- ============================================
    SELECT
        order_date,                                         -- date of the order
        AVG(DATEDIFF(DAY, ship_date, order_date)) AS average_shipping_delay -- avg days between shipping and order
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL AND ship_date IS NOT NULL
    GROUP BY order_date
    ORDER BY order_date;

-- ============================================
-- Task 10: What is the distribution of marital_status?
-- ============================================
    SELECT
        marital_status,               -- customer marital status
        COUNT(customer_key) AS total_customer -- number of customers per status
    FROM gold.dim_customers
    GROUP BY marital_status;

-- ============================================
-- Task 11:  What is the average maintenance cost by category? 
-- ============================================
    SELECT
        category,                    -- product category
        AVG(product_cost) AS avg_maintenance_cost -- average maintenance cost per category
    FROM gold.dim_products
    GROUP BY category
    ORDER BY avg_maintenance_cost;

-- ============================================
-- Task 12: What is the average sales_amount per order? 
-- ============================================
    SELECT
        order_number,                        -- unique order number
        AVG(sales) AS avg_sales,             -- average sales value for this order
        COUNT(DISTINCT order_number) AS total_customer, -- total number of distinct orders (should equal 1 per row here)
        AVG(sales)/COUNT(DISTINCT order_number) AS sales_per_order -- avg sales per order (redundant but illustrative)
    FROM gold.fact_sales
    GROUP BY order_number
    ORDER BY sales_per_order DESC;

-- ============================================
-- Task 13: What is the age distribution of customers based on birthdate? (e.g., average age,youngest, oldest). 
-- ============================================
    SELECT
        CASE
            WHEN DATEDIFF(YEAR, birth_date, GETDATE()) BETWEEN 20 AND 40 THEN 'average' -- age 20-40
            WHEN DATEDIFF(YEAR, birth_date, GETDATE()) BETWEEN 41 AND 60 THEN 'youngest' -- age 41-60
            ELSE 'oldest' -- age > 60
        END AS age_distribution,
        COUNT(customer_key) AS totalcustomer, -- number of customers in each age group
        COUNT(customer_key)*100.0/SUM(COUNT(customer_key)) OVER() AS percentage -- percentage of total customers
    FROM gold.dim_customers
    GROUP BY CASE
        WHEN DATEDIFF(YEAR, birth_date, GETDATE()) BETWEEN 20 AND 40 THEN 'average'
        WHEN DATEDIFF(YEAR, birth_date, GETDATE()) BETWEEN 41 AND 60 THEN 'youngest'
        ELSE 'oldest'
    END;

-- ============================================
-- Task 14: Which products are active based on start_date?
-- ============================================
    SELECT 
        product_id,   -- product identifier
        product_name  -- product name
    FROM gold.dim_products
    WHERE start_date <= GETDATE(); -- only products that started on or before today

-- ============================================
-- Task 15: Which order had the maximum sales_amount? 
-- ============================================
    WITH CTE_aggregation AS (
        SELECT
            order_number,               -- order ID
            MAX(sales) AS maximum_sales -- max sales value per order
        FROM gold.fact_sales
        GROUP BY order_number
    ),
    CTE_rank AS (
        SELECT *,
            RANK() OVER(ORDER BY maximum_sales DESC) AS rank_list -- rank orders by maximum sales
        FROM CTE_aggregation
    )
    SELECT *
    FROM CTE_rank
    WHERE rank_list = 1; -- top order(s) with max sales

-- ============================================
-- Task 16: Which countries have the highest number of customers? 
-- ============================================
    SELECT
        country,                  -- customer country
        COUNT(customer_key) AS totalcustomer -- number of customers
    FROM gold.dim_customers
    GROUP BY country
    ORDER BY totalcustomer DESC;

-- ============================================
-- Task 17: How many products were sold in total 
-- ============================================
    SELECT
        SUM(quantity) AS total_quantity_sold -- total items sold
    FROM gold.fact_sales;

-- ============================================
-- Task 18: How many customers share the same firstname/lastname?
-- ============================================
    SELECT
        firstname,                   -- customer first name
        COUNT(customer_key) AS totalcustomer -- number of customers sharing this first name
    FROM gold.dim_customers
    GROUP BY firstname
    ORDER BY totalcustomer DESC;

-- ============================================
-- Task 19: Are there any orders where shipping_date < order_date
-- ============================================
    SELECT *
    FROM gold.fact_sales
    WHERE ship_date < order_date; -- likely data error

-- ============================================
-- Task 20: Which products are sold the most (by quantity)?
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
-- Task 21: Which countries contribute the highest total revenue? 
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
-- Task 22: What is the average order value per customer? 
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
-- Task 23:Which categories are most popular among male vs female customers? 
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