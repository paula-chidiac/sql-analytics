/*
===============================================================================
Relatório de clientes
===============================================================================

Objetivo: Criar um relatório de clientes com as principais métricas, como:
  - Total de pedidos por clientes
  - Meses desde o último pedido
  - Média de gasto mensal
  - Média de gasto por pedido
  - Há quanto tempo é cliente da empresa (em meses)

===============================================================================
*/

-- Criação da view
DROP VIEW IF EXISTS gold.report_customers;
CREATE VIEW gold.report_customers AS
-- Query base
WITH base_query AS (
SELECT 
	f.order_number,
	f.product_key,
	f.order_date,
	f.sales_amount,
	f.quantity,
	c.customer_key,
	c.customer_number,
	c.first_name || ' ' || c.last_name AS customer_name,
	EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) AS age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL
),

-- Agregações
cust_aggregations AS (
	SELECT 
		customer_key,
		customer_number,
		customer_name,
		age,
		COUNT (DISTINCT order_number) AS total_orders,
		SUM (sales_amount) AS total_sales,
		SUM (quantity) AS total_quantity,
		COUNT (DISTINCT product_key) AS total_products,
		MAX (order_date) AS last_order_date,
		EXTRACT
			(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12
			+ EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))
			) AS lifespan_months
	FROM base_query
	GROUP BY 
		customer_key,
		customer_number,
		customer_name,
		age
)

-- Select principal
SELECT 
	customer_key,
	customer_number,
	customer_name,
	age,
	total_orders,
	total_sales,
	total_quantity,
	total_products,
	last_order_date,
	lifespan_months,
	CASE
		WHEN age < 20 THEN 'Under 20'
		WHEN age BETWEEN 20 AND 29 THEN '20-29'
		WHEN age BETWEEN 30 AND 39 THEN '30-39'
		WHEN age BETWEEN 40 AND 49 THEN '40-49'
		ELSE '50+'
	END AS age_group, 
	CASE 
    	WHEN lifespan_months >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan_months >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,
	EXTRACT
		(YEAR FROM AGE(NOW(), last_order_date)) * 12
    	+ EXTRACT(MONTH FROM AGE(NOW(), last_order_date))
		AS recency_months,
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders 
		END AS avg_order_value,
	CASE 
		WHEN lifespan_months = 0 THEN total_sales
    	ELSE ROUND(total_sales / lifespan_months, 2)
		END AS avg_monthly_spend
FROM cust_aggregations
