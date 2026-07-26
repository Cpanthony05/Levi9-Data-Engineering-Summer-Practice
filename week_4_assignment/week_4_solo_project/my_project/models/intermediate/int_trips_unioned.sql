-- models/intermediate/int_trips_unioned.sql
{{ union_tripdata(['stg_green_tripdata', 'stg_yellow_tripdata', 'stg_fhv_tripdata']) }}