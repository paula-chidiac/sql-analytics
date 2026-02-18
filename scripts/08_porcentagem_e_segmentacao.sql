/*
===============================================================================
Porcentagem e Segmentação
===============================================================================

Objetivo: Explorar partes do todo e segmentar informações.

Funções utilizadas:
  - NOT IN
  - DISTINCT
  - MIN / MAX
  - EXTRACT
  - SUM / AVG / COUNT

===============================================================================
*/

-- Porcentagem de vendas por categoria
WITH category_sales AS (
SELECT
	category,
	SUM(sales_amount) AS total_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON p.product_key = f.product_key
	GROUP BY category
) 

SELECT 
	category,
	total_sales,
	SUM(total_sales) OVER () overall_sales,
	ROUND((total_sales::numeric / SUM(total_sales) OVER()) * 100,2)::text || '%' AS total_percentage
	FROM category_sales
ORDER BY total_sales  	


-- Contagem de número de produtos por faixa de preço
WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
)
SELECT 
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;


-- Divisão de clientes por tempo de fidelidade + gastos
-- VIP:  >= 12 anos de fidelidade e gastou mais de 5000
-- Regular: >= 12 anos de fidelidade e gastou menos de 5000

WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        EXTRACT
			          (YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12
    		        + EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))
			          ) AS lifespan
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT 
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT 
        customer_key,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) AS segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;
