

-- ============================================
-- Task 1: How many unique customers are in the dataset?
-- ============================================
    SELECT
        COUNT(DISTINCT customer_key) AS totalcustomer -- total unique customers
    FROM gold.dim_customers;

-- ============================================
-- Task 2: What is the distribution of customers by country? 
-- ============================================
    SELECT
        country,                 -- customer country
        COUNT(customer_key) AS Totalcustomer -- total customers per country
    FROM gold.dim_customers
    GROUP BY country
    ORDER BY Totalcustomer DESC;

-- ============================================
-- Task 3: What percentage of customers are male vs female?
-- ============================================
    SELECT
        gender,                                  -- customer gender
        COUNT(customer_key) AS Totalcustomer,    -- number of customers per gender
        COUNT(customer_key)*100.0/SUM(COUNT(customer_key)) OVER() AS percent_value -- percentage per gender
    FROM gold.dim_customers
    GROUP BY gender;

-- ============================================
-- Task 4: What is the distribution of marital_status?
-- ============================================
    SELECT
        marital_status,               -- customer marital status
        COUNT(customer_key) AS total_customer -- number of customers per status
    FROM gold.dim_customers
    GROUP BY marital_status;

-- ============================================
-- Task 5: What is the age distribution of customers based on birthdate? (e.g., average age,youngest, oldest). 
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
-- Task 6: Which countries have the highest number of customers? 
-- ============================================
    SELECT
        country,                  -- customer country
        COUNT(customer_key) AS totalcustomer -- number of customers
    FROM gold.dim_customers
    GROUP BY country
    ORDER BY totalcustomer DESC;

-- ============================================
-- Task 7: How many customers share the same firstname/lastname?
-- ============================================
    SELECT
        firstname,                   -- customer first name
        COUNT(customer_key) AS totalcustomer -- number of customers sharing this first name
    FROM gold.dim_customers
    GROUP BY firstname
    ORDER BY totalcustomer DESC;