select
    null as vendor_id,
    pickup_datetime,
    dropoff_datetime,
    pulocationid as pickup_location_id,
    dolocationid as dropoff_location_id,
    null as passenger_count,
    null as trip_distance,
    null as fare_amount,
    null as tip_amount,
    null as total_amount,
    'fhv' as cab_type
from {{ source('nyc_taxi', 'fhv_tripdata') }}