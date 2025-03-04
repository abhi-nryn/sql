# Identify in sale table products whose total sales increased 2 months consecutively no hardcoding


CREATE TABLE sales (
    sale_id NUMBER PRIMARY KEY,
    product_name VARCHAR2(50),
    sale_date DATE,
    sale_amount NUMBER
);

INSERT INTO sales (sale_id, product_name, sale_date, sale_amount)
SELECT LEVEL, 
       'Product_' || TO_CHAR(MOD(LEVEL, 10) + 1), 
       DATE '2023-05-01' + MOD(LEVEL, 60), 
       CASE 
           WHEN EXTRACT(MONTH FROM (DATE '2023-05-01' + MOD(LEVEL, 60))) = 5 
           THEN TRUNC(DBMS_RANDOM.VALUE(100, 200))
           WHEN EXTRACT(MONTH FROM (DATE '2023-05-01' + MOD(LEVEL, 60))) = 6 
           THEN TRUNC(DBMS_RANDOM.VALUE(200, 300)) -- Increased range
           ELSE TRUNC(DBMS_RANDOM.VALUE(300, 400)) -- Further increased range
       END
FROM dual CONNECT BY LEVEL <= 600;

COMMIT;


WITH sales_summary AS (
    SELECT product_name,
           TO_CHAR(sale_date, 'YYYY-MM') AS sale_month,
           SUM(sale_amount) AS total_sales
    FROM sales
    GROUP BY product_name, TO_CHAR(sale_date, 'YYYY-MM')
), ranked_sales AS (
    SELECT product_name,
           sale_month,
           total_sales,
           LAG(total_sales) OVER (PARTITION BY product_name ORDER BY sale_month) AS prev_month_sales
    FROM sales_summary
)
SELECT DISTINCT product_name
FROM ranked_sales
WHERE prev_month_sales IS NOT NULL AND total_sales > prev_month_sales;


