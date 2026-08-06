select
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    cast(start_station_id as varchar) as start_station_id,
    start_station_name,
    start_lat,
    start_lng,
    cast(end_station_id as varchar) as end_station_id,
    end_station_name,
    end_lat,
    end_lng,
    member_casual,
    datediff('second', started_at, ended_at) as trip_duration_seconds
from {{ source('divvy', 'trips') }}
qualify row_number() over (
    partition by ride_id
    order by load_month asc, (ended_at > started_at) desc
) = 1