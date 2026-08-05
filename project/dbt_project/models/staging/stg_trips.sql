select
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_station_id,
    start_station_name,
    start_lat,
    start_lng,
    end_station_id,
    end_station_name,
    end_lat,
    end_lng,
    member_casual,
    datediff('second', started_at, ended_at) as trip_duration_seconds
from {{ source('divvy', 'trips') }}