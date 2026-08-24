from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator

from extract_trips import extract_all_pending
from load_trips import load_bronze, validate_bronze

DBT_DIR = "/opt/airflow/dbt_project"

default_args = {"owner": "divvy", "retries": 1}

with DAG(
    dag_id="divvy_pipeline",
    default_args=default_args,
    start_date=datetime(2026, 7, 1),
    schedule=None,
    catchup=False,
    max_active_tasks=1,  # DuckDB is single-writer
    tags=["divvy", "duckdb", "dbt"],
    doc_md="""
    ### Divvy pipeline
    1. **extract** — source_csv/*.csv -> raw/*.parquet (idempotent, skips already-landed months)
    2. **load** — raw/*.parquet -> bronze.trips in DuckDB
    3. **validate_load** — fail fast if bronze is empty
    4. **dbt_snapshot** — station SCD2
    5. **dbt_run** — staging -> intermediate -> marts (incremental fct_trips)
    6. **dbt_test** — schema + custom tests; fails DAG on any ERROR-severity failure
    """,
) as dag:

    extract = PythonOperator(task_id="extract", python_callable=extract_all_pending)
    load = PythonOperator(task_id="load", python_callable=load_bronze)
    validate_load = PythonOperator(task_id="validate_load", python_callable=validate_bronze)

    dbt_snapshot = BashOperator(
        task_id="dbt_snapshot",
        bash_command=f"cd {DBT_DIR} && dbt --no-partial-parse snapshot --profiles-dir .",
    )
    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=f"cd {DBT_DIR} && dbt --no-partial-parse run --profiles-dir .",
    )
    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=f"cd {DBT_DIR} && dbt --no-partial-parse test --profiles-dir .",
    )

    extract >> load >> validate_load >> dbt_snapshot >> dbt_run >> dbt_test