select start_station_id as station_id, start_station_name as station_name,
       start_lat as latitude, start_lng as longitude, started_at as observed_at
from {{ ref('stg_trips') }}
where start_station_id is not null

union all

select end_station_id, end_station_name, end_lat, end_lng, ended_at
from {{ ref('stg_trips') }}
where end_station_id is not null