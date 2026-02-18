/*
===============================================================================
Carregamento dos dados
===============================================================================

Este script cria todo o dataset utilizado no projeto, com base nos CSVs disponíveis na pasta datasets. 

ATENÇÃO: lembre-se de atualizar os destinos dos arquivos antes de rodar o script.
===============================================================================
*/

-- Clientes (gold.dim_customers)
RAISE NOTICE '>> Apagando gold.dim_customers (se houver)';
DROP TABLE IF EXISTS gold.dim_customers;
RAISE NOTICE '>> Criando gold.dim_customers';
CREATE TABLE gold.dim_customers (
    customer_key INT,
    customer_id TEXT,
    customer_number TEXT,
    first_name TEXT,
    last_name TEXT,
    country TEXT,
    marital_status TEXT,
    gender TEXT,
    birthdate DATE,
    create_date DATE
);

RAISE NOTICE '>> Copiando dados do CSV para gold.dim_customers';
COPY gold.dim_customers_csv FROM 'CAMINHO_DO_ARQUIVO' DELIMITER ',' CSV HEADER;

-- Produtos (gold.dim_products)
RAISE NOTICE '>> Apagando gold.dim_product (se houver';
DROP TABLE IF EXISTS gold.dim_products_csv;
RAISE NOTICE '>> Criando gold.dim_products';
CREATE TABLE gold.dim_products_csv (
    product_key INT,
    product_id TEXT,
    product_number TEXT,
    product_name TEXT,
    category_id TEXT,
    category TEXT,
    subcategory TEXT,
    maintenance TEXT,
    cost NUMERIC,
    product_line TEXT,
    start_date DATE
);
RAISE NOTICE '>> Copiando dados do CSV para gold.dim_products';
COPY gold.dim_products_csv FROM 'CAMINHO_DO_ARQUIVO' DELIMITER ',' CSV HEADER;


-- Vendas (gold.fact_sales)

RAISE NOTICE '>> Apagando gold.fact_sales (se houver)';
DROP TABLE IF EXISTS gold.fact_sales_csv;
RAISE NOTICE '>> Criando gold.fact_sales';
CREATE TABLE gold.fact_sales_csv (
    order_number TEXT,
    product_key INT,
    customer_key INT,
    order_date DATE,
    shipping_date DATE,
    due_date DATE,
    sales_amount NUMERIC,
    quantity NUMERIC,
    price NUMERIC
);

RAISE NOTICE '>> Copiando dados do CSV para gold.dim_products';
COPY gold.fact_sales_csv 
FROM 'CAMINHO_DO_ARQUIVO' DELIMITER ',' CSV HEADER;
