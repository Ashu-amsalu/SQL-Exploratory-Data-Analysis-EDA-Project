

-- ============================================
-- Task 1: How many total sales transactions are recorded? 
-- ============================================
    SELECT
        COUNT(sales) AS total_number_transaction -- total number of sales records
    FROM gold.fact_sales;

-- ============================================
-- Task 2: What is the earliest and latest order_date? 
-- ============================================
    SELECT
        MAX(order_date) AS latest_order, -- most recent order date
        MIN(order_date) AS earliest_order -- earliest order date
    FROM gold.fact_sales;

-- ============================================
-- Task 3: What is the distribution of order_date vs shipping_date (average shipping delay)? 
-- ============================================
    SELECT
        order_date,                                         -- date of the order
        AVG(DATEDIFF(DAY, ship_date, order_date)) AS average_shipping_delay -- avg days between shipping and order
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL AND ship_date IS NOT NULL
    GROUP BY order_date
    ORDER BY order_date;

-- ============================================
-- Task 4: What is the average sales_amount per order? 
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
-- Task 5: Which order had the maximum sales_amount? 
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
-- Task 6: How many products were sold in total 
-- ============================================
    SELECT
        SUM(quantity) AS total_quantity_sold -- total items sold
    FROM gold.fact_sales;

-- ============================================
-- Task 7: Are there any orders where shipping_date < order_date
-- ============================================
    SELECT *
    FROM gold.fact_sales
    WHERE ship_date < order_date; -- likely data error