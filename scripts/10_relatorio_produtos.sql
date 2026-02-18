/*
===============================================================================
Relatório de clientes
===============================================================================

Objetivo: Criar um relatório de produtos com as principais métricas, como:
  - Total de pedidos
  - Total vendido (em $ e em quantidade)
  - Meses desde a última venda
  - Média de gasto mensal
  - Média de gasto por pedido

===============================================================================
*/

-- Criação da view
DROP VIEW IF EXISTS gold.report_products;
CREATE VIEW gold.report_products AS

-- Query base
WITH base_query AS (
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL
),

-- Agregações
prod_aggregations AS (
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
		EXTRACT
			(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12
            + EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date)))
        	AS lifespan,
        MAX(order_date) AS last_sale_date,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        ROUND(AVG(sales_amount::numeric / NULLIF(quantity,0)), 1) AS avg_selling_price
    FROM base_query
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)

-- Select principal
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    EXTRACT
		(YEAR FROM AGE(NOW(), last_sale_date)) * 12
        + EXTRACT(MONTH FROM AGE(NOW(), last_sale_date))
    	AS recency_in_months,
    CASE
        WHEN total_sales > 50000 THEN 'High'
        WHEN total_sales >= 10000 THEN 'Medium'
        ELSE 'Low'
    END AS product_performance,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue
FROM prod_aggregations;
