import os
from pathlib import Path
import duckdb

def load_bronze() -> None:
    duckdb_path = os.environ.get("DIVVY_DUCKDB_PATH", "warehouse.duckdb")
    raw_glob = str(Path(os.environ.get("DIVVY_RAW_DIR", "raw")) / "*-divvy-tripdata.parquet")

    con = duckdb.connect(duckdb_path)
    con.execute("CREATE SCHEMA IF NOT EXISTS bronze")
    con.execute(f"""
        CREATE OR REPLACE TABLE bronze.trips AS
        SELECT * FROM read_parquet('{raw_glob}', union_by_name=true)
    """)
    n = con.execute("SELECT COUNT(*) FROM bronze.trips").fetchone()[0]
    print(f"bronze.trips -> {n} rows")
    con.close()

def validate_bronze() -> None:
    duckdb_path = os.environ.get("DIVVY_DUCKDB_PATH", "warehouse.duckdb")
    con = duckdb.connect(duckdb_path, read_only=True)
    n = con.execute("SELECT COUNT(*) FROM bronze.trips").fetchone()[0]
    con.close()
    if n == 0:
        raise RuntimeError("bronze.trips is empty — aborting before dbt runs")
    print(f"OK bronze.trips -> {n} rows")