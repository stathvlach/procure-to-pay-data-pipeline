from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator
from datetime import datetime
from commons import BASE_SQL_PATH

with DAG(
    dag_id="populate_purchase_orders",
    start_date=datetime(2026, 1, 1),
    schedule_interval=None,
    catchup=False,
    template_searchpath=[BASE_SQL_PATH],
    tags=["postgres", "operational"],
) as dag:

    populate_synthetic_ekko = PostgresOperator(
        task_id="populate_synthetic_ekko",
        postgres_conn_id="postgres_default",
        sql="operational/synthetic_transactional/300_generate_EKKO_clean.sql"
    )

    populate_synthetic_ekpo = PostgresOperator(
        task_id="populate_synthetic_ekpo",
        postgres_conn_id="postgres_default",
        sql="operational/synthetic_transactional/310_generate_EKPO_clean.sql"
    )


    populate_synthetic_ekko >> populate_synthetic_ekpo