# Divvy Bikeshare Data Pipeline Documentation

## 1. Executive summary

This project is a local and fully orchestrated data pipeline for Divvy's public bikeshare trip data. The purpose of the project is to provide business information about Chicago's bikeshare riders that use the system: where do bikes stack up, what are the differences between the habits of members and casual riders, how riding habits have changed over the years and which stations changed their name.

## 2. Dataset description

**Source**: Divvy Bikeshare trip data, published at [https://divvybikes.com/system-data](https://divvybikes.com/system-data)

**Format**: ZIP archive that contains a single CSV information about the trips in a month. Each trip has multiple information related to it (ride_id, rideable_type, started_at, ended_at, start/end station id and name, start/end latitude and longitude, member_casual)

**Update frequency**: monthly

**Scoping decision:** CSVs were downloaded manually.

**Volume loaded:** 25 distinct months between April 2020 and May 2026 in order to notice different changes related to the dataset and the habits of the customers

## 3. Project structure walkthrough

dags/ingest_dag.py: the airflow DAG definition, it contains six tasks, retry logic, dependencies

scripts/extract_trips.py: converts source_csv/*.csv into raw/*.parquet idempotently

scripts/load_trips.py: loads raw/*.parquet into DuckDB bronze

dbt_project/models/staging/: stg_trips.sql(source) and schema.yml(tests)

dbt_project/models/intermediate/: int_station_observations.sql

dbt_project/snapshots/: dim_station_snapshot.sql; station name change snapshot definition

dbt_project/model/marts/: fct_trips.sql with the aggregated business information and the 5 marts that answer the business questions

dbt_project/tests/: assert_positive_trip_duration.sql

source_csv/: manually downloaded CSVs

raw/: parquet files for each CSV

warehouse.duckdb: database file

docs/project_documentation.docx: this document

screenshots/: screenshots used for the documentation/presentation

docker-compose.yml_env: airflow + postgres container definitions and their configurations

## 8. How to run

From a clean checkout, with warehouse.duckdb, raw/ and dbt target directories deleted

- Place Divvy monthly CSVs (unzipped) into source_csv/ at the project root.
- Copy .env.example to .env and adjust ports/credentials if needed.
- From the project root, run: docker compose up - this provisions Postgres (Airflow's metadata DB), runs airflow-init, and starts the webserver and scheduler.
- Open the Airflow UI (the port configured in .env), log in, locate divvy_pipeline, unpause it, and trigger a manual run.
- Confirm all six tasks succeed in the Graph view.
- To inspect results directly: duckdb warehouse.duckdb -c "select * from fct_trips limit 5;" (or any mart).
- To regenerate dbt docs: cd dbt_project && dbt docs generate --profiles-dir . && dbt docs serve --profiles-dir . --port .
