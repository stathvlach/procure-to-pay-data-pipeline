from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
from commons import run_sql_folder

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
        op_args=["operational/init"]
    )

    config_task = PythonOperator(
        task_id="config_schema",
        python_callable=run_sql_folder,
        op_args=["operational/config"]
    )

    synthetic_task = PythonOperator(
        task_id="load_synthetic_data",
        python_callable=run_sql_folder,
        op_args=["operational/synthetic_master"]
    )

    init_task >> config_task >> synthetic_task