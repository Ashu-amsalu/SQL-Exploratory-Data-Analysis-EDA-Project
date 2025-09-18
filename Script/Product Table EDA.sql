

-- ============================================
-- Task 1: How many unique products are listed? 
-- ============================================
    SELECT
        COUNT(DISTINCT product_name) AS totalnumber_of_products -- total unique products
    FROM gold.dim_products;

-- ============================================
-- Task 2: How many categories and subcategories exist, and how many products fall into each?
-- ============================================
    SELECT
        category,                -- product category
        subcategory,             -- product subcategory
        COUNT(product_key) AS totalproducts -- total products in each category/subcategory
    FROM gold.dim_products
    GROUP BY category, subcategory
    ORDER BY category;

-- ============================================
-- Task 3: Which products have the highest and lowest price? 
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
-- Task 4:  What is the average maintenance cost by category? 
-- ============================================
    SELECT
        category,                    -- product category
        AVG(product_cost) AS avg_maintenance_cost -- average maintenance cost per category
    FROM gold.dim_products
    GROUP BY category
    ORDER BY avg_maintenance_cost;

-- ============================================
-- Task 5: Which products are active based on start_date?
-- ============================================
    SELECT 
        product_id,   -- product identifier
        product_name  -- product name
    FROM gold.dim_products
    WHERE start_date <= GETDATE(); -- only products that started on or before today

-- ============================================
-- Task 6: How many products were sold in total 
-- ============================================
    SELECT
        SUM(quantity) AS total_quantity_sold -- total items sold
    FROM gold.fact_sales;