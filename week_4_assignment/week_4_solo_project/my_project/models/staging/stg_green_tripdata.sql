-- models/staging/stg_green_tripdata.sql
select
    vendorid as vendor_id,
    lpep_pickup_datetime as pickup_datetime,
    lpep_dropoff_datetime as dropoff_datetime,
    pulocationid as pickup_location_id,
    dolocationid as dropoff_location_id,
    passenger_count,
    trip_distance,
    {{ clean_amount('fare_amount') }} as fare_amount,
    {{ clean_amount('tip_amount') }} as tip_amount,
    total_amount,
    'green' as cab_type
from {{ source('nyc_taxi', 'green_tripdata') }}