# Identify in sale table products whose total sales increased from May to June and further increased from June to July

-- Create a sample sales table
CREATE TABLE sales (
    sale_id NUMBER PRIMARY KEY,
    product_name VARCHAR2(50),
    sale_date DATE,
    sale_amount NUMBER
);

-- Insert sample data with an increasing trend for some products
INSERT INTO sales (sale_id, product_name, sale_date, sale_amount)
SELECT level, 
       'Product_' || TO_CHAR(MOD(level, 10) + 1), 
       DATE '2023-05-01' + MOD(level, 60), 
       CASE 
           WHEN EXTRACT(MONTH FROM (DATE '2023-05-01' + MOD(level, 60))) = 5 
           THEN TRUNC(DBMS_RANDOM.VALUE(100, 200))
           WHEN EXTRACT(MONTH FROM (DATE '2023-05-01' + MOD(level, 60))) = 6 
           THEN TRUNC(DBMS_RANDOM.VALUE(200, 300)) -- Increased range
           ELSE TRUNC(DBMS_RANDOM.VALUE(300, 400)) -- Further increased range
       END
FROM dual CONNECT BY level <= 600;

COMMIT;

-- Query to find products whose sales increased in summer (June and July)
WITH sales_summary AS (
    SELECT product_name,
           EXTRACT(MONTH FROM sale_date) AS sale_month,
           SUM(sale_amount) AS total_sales
    FROM sales
    WHERE EXTRACT(MONTH FROM sale_date) IN (5, 6, 7)  -- Considering May, June, July
    GROUP BY product_name, EXTRACT(MONTH FROM sale_date)
)
SELECT s1.product_name
FROM sales_summary s1
JOIN sales_summary s2 ON s1.product_name = s2.product_name
WHERE s1.sale_month = 6 AND s2.sale_month = 5 AND s1.total_sales > s2.total_sales
INTERSECT
SELECT s1.product_name
FROM sales_summary s1
JOIN sales_summary s2 ON s1.product_name = s2.product_name
WHERE s1.sale_month = 7 AND s2.sale_month = 6 AND s1.total_sales > s2.total_sales;
