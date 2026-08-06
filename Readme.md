# ❄️ Data Engineering with Snowflake

Hands-on exercises and reference material for learning **Snowflake SQL** and **data engineering workflows**, built on a small e-commerce dataset (customers, orders, order items, products).

The repository moves from Snowflake fundamentals (stages, `COPY INTO`, schema setup) to advanced, Snowflake-native SQL: window functions, CTEs, `QUALIFY`, pivoting, and semi-structured data handling — plus programmatic access from Python.

## 📁 Repository structure

```
Snowflake/
├── SnowflakeStart.txt        # Getting started: warehouse, database, stage, COPY INTO (Tasty Bytes)
├── code/
│   └── snowflake_connect.py  # Connect to Snowflake from Python and run a JOIN query
├── data/
│   ├── customers.csv         # Customer master data (id, name, email, age, country, city)
│   ├── orders.csv            # Order headers (id, customer_id, date, amount, status)
│   ├── order_items.csv       # Order line items (order_id, product_id, quantity, unit_price)
│   └── products.csv          # Product catalog (id, name, category, price, stock)
├── data_encoding/
│   ├── encoding.py           # Detect file encoding with chardet, read UTF-16 CSV
│   └── kyoto_restaurants.csv # UTF-16 encoded sample file
└── queries/
    ├── MainQueries.sql       # Base SELECTs on the loaded tables
    ├── Queries_1.sql         # SQL fundamentals: filtering, sorting, aggregates, GROUP BY / HAVING
    ├── Queries_2.sql         # CTEs: basic, chained, and recursive
    ├── Queries_3.sql         # Joins: INNER, LEFT, multi-table
    ├── Queries_4.sql         # Window functions: ROW_NUMBER, RANK, running totals, LAG/LEAD, NTILE
    ├── Queries_5.sql         # QUALIFY clause (Snowflake-specific row filtering on window results)
    ├── Queries_6.sql         # Self joins, cross joins, per-customer analytics with windows
    ├── Queries_7.sql         # PIVOT, set operators (UNION/INTERSECT/EXCEPT), ROLLUP, CUBE, LISTAGG
    └── Queries_8.sql         # Conditional aggregation, ARRAY_AGG, FLATTEN for semi-structured data
```

## 🗄️ The dataset

A minimal relational model, ideal for practicing joins and window functions:

```
customers (customer_id) ──< orders (order_id) ──< order_items >── products (product_id)
```

| Table         | Grain                | Key columns                                      |
|---------------|----------------------|--------------------------------------------------|
| `customers`   | one row per customer | customer_id, name, email, age, country, city     |
| `orders`      | one row per order    | order_id, customer_id, order_date, amount, status|
| `order_items` | one row per line     | order_id, product_id, quantity, unit_price       |
| `products`    | one row per product  | product_id, name, category, price, stock         |

## 🚀 Getting started

### 1. Set up the Snowflake environment

`SnowflakeStart.txt` walks through the classic quickstart flow:

```sql
USE ROLE accountadmin;
USE WAREHOUSE compute_wh;
CREATE OR REPLACE DATABASE tasty_bytes_sample_data;
-- create schema, table, external S3 stage, then:
COPY INTO tasty_bytes_sample_data.raw_pos.menu
FROM @tasty_bytes_sample_data.public.blob_stage/raw_pos/menu/;
```

### 2. Load the e-commerce CSVs

Upload the four files in `data/` via Snowsight (**Ingestion » Add Data » Load data into a Table**, or the **Upload local files** quick action), or stage them and use `COPY INTO`. Schema detection with `INFER_SCHEMA` + `CREATE TABLE ... USING TEMPLATE` works well for these files.

### 3. Work through the queries

The `queries/` files are ordered by difficulty — from `Queries_1.sql` (fundamentals) to `Queries_8.sql` (arrays and semi-structured data). Each file is self-contained and commented.

## 🐍 Python connectivity

`code/snowflake_connect.py` connects via the official connector and runs a customer/orders join.

```bash
pip install "snowflake-connector-python[pandas]"
export SNOWFLAKE_PASSWORD="your_password"
python code/snowflake_connect.py
```

Credentials are read from environment variables — never hardcoded. Adapt the `account`, `database`, and `warehouse` values in `SNOWFLAKE_CONFIG` to your own account.

## 🔤 Bonus: file encoding detection

`data_encoding/encoding.py` shows how to detect a CSV's encoding with `chardet` before loading — the included `kyoto_restaurants.csv` is UTF-16, a common real-world gotcha when ingesting files into Snowflake.

## 🧠 Key Snowflake concepts covered

- **Stages & `COPY INTO`** — internal and external (S3) stages for file-based loading
- **Window functions** — `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `LAG`/`LEAD`, `FIRST_VALUE`/`LAST_VALUE`, `NTILE`, running totals and moving averages
- **`QUALIFY`** — Snowflake's elegant way to filter on window function results without subqueries
- **CTEs** — including chained and recursive CTEs
- **Advanced aggregation** — `GROUPING SETS`, `ROLLUP`, `CUBE`, `LISTAGG`, conditional aggregates with `CASE`
- **Semi-structured data** — `ARRAY_AGG`, `OBJECT_CONSTRUCT`, `PARSE_JSON`, `FLATTEN`
- **Set operators & PIVOT** — `UNION [ALL]`, `INTERSECT`, `EXCEPT`, row-to-column pivoting

## 🗺️ Roadmap

- [ ] Snowpark (DataFrame API for Python)
- [ ] Streamlit dashboards on Snowflake data
- [ ] Orchestration and scheduling with Airflow
- [ ] dbt models on top of the e-commerce schema

## 👤 Author

**Alket Cecaj** — [GitHub](https://github.com/alketcecaj12)
