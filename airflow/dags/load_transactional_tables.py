from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from datetime import datetime
import os

BASE_SQL_PATH = "/opt/airflow/src/sql/operational"


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


with DAG(
    dag_id="operational_schema_setup",
    start_date=datetime(2024, 1, 1),
    schedule_interval=None,
    catchup=False,
    tags=["postgres", "bootstrap"],
) as dag:

    init_task = PythonOperator(
        task_id="init_schema",
        python_callable=run_sql_folder,
        op_args=["init"]
    )

    config_task = PythonOperator(
        task_id="config_schema",
        python_callable=run_sql_folder,
        op_args=["config"]
    )

    synthetic_task = PythonOperator(
        task_id="load_synthetic_data",
        python_callable=run_sql_folder,
        op_args=["synthetic"]
    )

    init_task >> config_task >> synthetic_task