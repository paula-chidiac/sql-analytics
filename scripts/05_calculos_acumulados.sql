/*
===============================================================================
Cálculo de acumulados
===============================================================================

Objetivo: Calcular as vendas acumuladas por ano e o preço médio acumulado.

Funções utilizadas:
  - SUM
  - ROUND
  - DATE_TRUNC
  - OVER()

===============================================================================
*/

SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
	ROUND(AVG(avg_price) OVER (ORDER BY order_date),2) AS cumulative_avg_price
FROM
(
    SELECT 
        DATE_TRUNC('month', order_date)::date AS order_date,
        SUM(sales_amount) AS total_sales,
        ROUND(AVG(price),2) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATE_TRUNC('month', order_date)
)
