from airflow.providers.postgres.hooks.postgres import PostgresHook
import os

BASE_SQL_PATH = "/opt/airflow/sql/"

def run_sql_folder(folder_name):
    folder_path = os.path.join(BASE_SQL_PATH, folder_name)

    sql_files = sorted([
        f for f in os.listdir(folder_path)
        if f.endswith(".sql")
    ])

    hook = PostgresHook(postgres_conn_id="postgres_default")
    conn = hook.get_conn()
    conn.autocommit = True

    cursor = conn.cursor()

    for sql_file in sql_files:
        full_path = os.path.join(folder_path, sql_file)

        print(f"Executing: {full_path}")

        with open(full_path, "r", encoding="utf-8") as f:
            sql = f.read()

        cursor.execute(sql)

    cursor.close()
    conn.close()
