"""
Connessione a Snowflake ed esecuzione di una query con JOIN semplice.

Prerequisiti:
    pip install "snowflake-connector-python[pandas]"

Uso:
    export SNOWFLAKE_PASSWORD="la_tua_password"
    python snowflake_join_query.py
"""

import os
import snowflake.connector

# --- Configurazione (adatta ai tuoi valori) ---
SNOWFLAKE_CONFIG = {
    "account": "xy12345.eu-central-1",   # il tuo account identifier
    "user": "ALKETCECAJ",
    "password": os.environ["SNOWFLAKE_PASSWORD"],  # mai hardcoded!
    "warehouse": "COMPUTE_WH",
    "database": "MY_TEST_DB",
    "schema": "PUBLIC",
    "role": "ACCOUNTADMIN",
}

# --- Query con una JOIN semplice ---
QUERY = """
    SELECT
        c.customer_id,
        c.customer_name,
        o.order_id,
        o.order_date,
        o.total_amount
    FROM customers AS c
    INNER JOIN orders AS o
        ON c.customer_id = o.customer_id
    ORDER BY o.order_date DESC
    LIMIT 20
"""


def main():
    conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
    cur = None
    try:
        cur = conn.cursor()
        cur.execute(QUERY)

        # Stampa i risultati riga per riga
        for row in cur.fetchall():
            print(row)

        # In alternativa, come DataFrame pandas:
        # cur.execute(QUERY)
        # df = cur.fetch_pandas_all()
        # print(df.head())

    finally:
        if cur is not None:
            cur.close()
        conn.close()
        print("Connessione chiusa.")


if __name__ == "__main__":
    main()
