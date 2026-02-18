/*
===============================================================================
Evolução temporal
===============================================================================

Objetivo: Visualizar evolução das vendas do negócio ao longo dos anos/meses.

Funções utilizadas:
  - DATE_TRUNC
  - SUM / COUNT
  - DISTINCT
  - EXTRACT

===============================================================================
*/

-- Visão geral com ano e data 

SELECT
    DATE_TRUNC('month', order_date)::date AS order_date,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity_sold
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY order_date;

-- Visão apenas por anos

SELECT
    EXTRACT(YEAR FROM order_date)  AS order_year,
    SUM(sales_amount)              AS total_sales,
    COUNT(DISTINCT customer_key)   AS total_customers,
    SUM(quantity)                  AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY
    EXTRACT(YEAR FROM order_date)
ORDER BY
    EXTRACT(YEAR FROM order_date);

-- Visão apenas por meses

SELECT
    EXTRACT(MONTH FROM order_date) AS order_year,
    SUM(sales_amount)              AS total_sales,
    COUNT(DISTINCT customer_key)   AS total_customers,
    SUM(quantity)                  AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY
    EXTRACT(MONTH FROM order_date)
ORDER BY
    EXTRACT(MONTH FROM order_date);
