/*
===============================================================================
Exploração inicial
===============================================================================

Objetivo: Explorar informações das tabelas/views e dados básicos de negócio.

Funções utilizadas:
  - NOT IN
  - DISTINCT
  - MIN / MAX
  - EXTRACT
  - SUM / AVG / COUNT

===============================================================================
*/

-- Objetos do datawarehouse
SELECT 
	table_catalog,
  table_schema,
  table_name,
  table_type
FROM information_schema.tables
WHERE table_schema NOT IN ('pg_catalog', 'information_schema'); -- Exclui tabelas do sistema

-- Exibe as colunas do datawarehouse
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns 
WHERE table_schema NOT IN ('pg_catalog', 'information_schema'); -- Exclui tabelas do sistema

-- Países dos clientes
SELECT DISTINCT country FROM gold.dim_customers

-- Categorias e subcategorias de produtos
SELECT DISTINCT category, subcategory, product_name FROM gold.dim_products
ORDER BY category, subcategory, product_name

-- Primeira compra, a última e a diferença entre elas em anos.
SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) AS order_range_years
FROM gold.fact_sales;

-- Cliente mais antigo e o mais novo
SELECT
	MIN(birthdate) AS oldest_birthdate,
	EXTRACT(YEAR FROM AGE(MIN(birthdate))) AS oldest_age,
	MAX(birthdate) AS newest_birthdate,
	EXTRACT(YEAR FROM AGE(MAX(birthdate))) AS youngest_age
FROM gold.dim_customers

-- Total de receita
SELECT SUM(sales_amount) AS total_sales
FROM gold.fact_sales

-- Quantidade total de produtos vendidos
SELECT SUM(quantity) AS totaL_quantity
FROM gold.fact_sales

-- Preço médio dos produtos vendidos
SELECT ROUND(AVG(price),2) AS avg_price
FROM gold.fact_sales

-- Total de pedidos
SELECT COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales

-- Total de produtos
SELECT COUNT(product_key) AS total_products
FROM gold.fact_sales

-- Exibe o total de clientes
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers

-- Exibe o total de clientes que realizaram pelo menos um pedido
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM gold.fact_sales
