import duckdb
print(duckdb.sql("select * from 'raw/2020-04-divvy-tripdata.parquet' limit 5"))
