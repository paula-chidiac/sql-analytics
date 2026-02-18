/*
===============================================================================
Medidas x Dimensões
===============================================================================

Objetivo: Cruzar medidas com dimensões para geração de insights.

Funções utilizadas:
  - SUM / AVG / COUNT
  - LEFT JOIN
  - GROUP BY / ORDER BY

===============================================================================
*/


-- Exibe número de clientes por país
SELECT
	country,
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC

-- Exibe número de clientes por gênero
SELECT
	gender,
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC

-- Exibe número de clientes por status civil
SELECT
	marital_status,
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY marital_status
ORDER BY total_customers DESC

-- Exibe número de clientes por gênero
SELECT
	DISTINCT category,
	COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC

-- Exibe custo médio por categoria
SELECT
	category,
	ROUND(AVG(cost),2) AS avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC

-- Total de receita por categoria
SELECT 
	p.category,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON p.product_key = f.product_key	
GROUP BY category
ORDER BY total_revenue DESC

-- Total de receita por cliente
SELECT 
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key	
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_revenue DESC

-- Distribuição das vendas em países
SELECT 
	c.country,
	SUM(f.quantity) AS total_items_sold
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key	
GROUP BY c.country
ORDER BY total_items_sold DESC
