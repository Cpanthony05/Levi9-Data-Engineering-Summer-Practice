# scripts/extract_trips.py
"""
Convert manually-downloaded Divvy CSVs into Parquet, landed in raw/,
partitioned by year-month. Idempotent: skips months already landed.
"""
from __future__ import annotations
import os, re
from pathlib import Path
import duckdb

SOURCE_DIR = Path(os.environ.get("DIVVY_SOURCE_DIR", "source_csv"))
RAW_DIR = Path(os.environ.get("DIVVY_RAW_DIR", "raw"))

def extract_month(csv_path: Path) -> str:
    match = re.match(r"(\d{4})(\d{2})", csv_path.stem)
    year_month = f"{match.group(1)}-{match.group(2)}"
    out_path = RAW_DIR / f"{year_month}-divvy-tripdata.parquet"

    if out_path.exists():
        print(f"SKIP {year_month}: already landed at {out_path}")
        return str(out_path)

    RAW_DIR.mkdir(parents=True, exist_ok=True)
    con = duckdb.connect()
    con.execute(f"""
        COPY (SELECT *, '{year_month}' AS load_month
              FROM read_csv_auto('{csv_path}', union_by_name=true))
        TO '{out_path}' (FORMAT PARQUET)
    """)
    con.close()
    print(f"LANDED {year_month} -> {out_path}")
    return str(out_path)


def extract_all_pending() -> list[str]:
    """Called by the Airflow task; converts every CSV sitting in source_csv/."""
    return [extract_month(p) for p in SOURCE_DIR.glob("*.csv")]