/*
===============================================================================
Performance anual dos produtos (Year On Year)
===============================================================================

Objetivo: Analisar a performance anual de produtos comparando as vendas atuais com as vendas do ano passado e a média de vendas.

Funções utilizadas:
  - CTE
  - Subquery
  - CASE/WHEN
  - LAG ()
  - AVG () OVER ()
  - PARTITION BY
  - EXTRACT
  - SUM / AVG
  - LEFT JOIN

===============================================================================
*/


WITH yearly_product_sales AS (
    SELECT
        EXTRACT(YEAR FROM f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY 
       EXTRACT(YEAR FROM f.order_date),
        p.product_name
)
SELECT
    *,
    current_sales - avg_sales AS difference_avg,
    CASE 
        WHEN current_sales - avg_sales > 0 THEN 'Above average'
        WHEN current_sales - avg_sales < 0 THEN 'Below average'
        ELSE 'Average'
    END AS avg_change,
    current_sales - previous_year_sales AS difference_py,
    CASE 
        WHEN current_sales - previous_year_sales > 0 THEN 'Increase'
        WHEN current_sales - previous_year_sales < 0 THEN 'Decrease'
        ELSE 'No change'
    END AS py_change
FROM (
    SELECT
        *,
        ROUND(AVG(current_sales) OVER (PARTITION BY product_name),2) AS avg_sales,
        LAG(current_sales) OVER (
            PARTITION BY product_name 
            ORDER BY order_year
        ) AS previous_year_sales
    FROM yearly_product_sales
)
ORDER BY product_name, order_year;
