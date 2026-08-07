with trip_geo as (
    select
        f.ride_id,
        f.member_casual,
        f.trip_duration_seconds,
        f.start_station_id,
        f.start_station_name,
        f.end_station_id,
        f.end_station_name,
        extract(hour from f.started_at) as start_hour,
        s.start_lat, s.start_lng, s.end_lat, s.end_lng
    from {{ ref('fct_trips') }} f
    join {{ ref('stg_trips') }} s
        on f.ride_id = s.ride_id
    where f.start_station_id is not null
      and f.end_station_id is not null
      and f.trip_duration_seconds > 0   -- undefined speed otherwise; excluded here, not in fct_trips itself
),

with_distance as (
    select
        *,
        3958.8 * 2 * asin(sqrt(
            power(sin(radians(end_lat - start_lat) / 2), 2) +
            cos(radians(start_lat)) * cos(radians(end_lat)) *
            power(sin(radians(end_lng - start_lng) / 2), 2)
        )) as distance_miles
    from trip_geo
),

bucketed as (
    select
        *,
        case
            when start_hour between 5 and 10 then 'Morning'
            when start_hour between 11 and 15 then 'Midday'
            when start_hour between 16 and 20 then 'Evening'
            else 'Night'
        end as time_of_day
    from with_distance
    where distance_miles > 0.05   -- excludes same-station / negligible-distance loops
)

select
    start_station_id,
    start_station_name,
    end_station_id,
    end_station_name,
    time_of_day,
    member_casual,
    count(*) as trip_count,
    round(avg(distance_miles), 2) as avg_distance_miles,
    round(avg(trip_duration_seconds) / 60.0, 1) as avg_duration_minutes,
    round(avg((trip_duration_seconds / 60.0) / distance_miles), 2) as avg_minutes_per_mile,
    round(avg(distance_miles / (trip_duration_seconds / 3600.0)), 2) as avg_speed_mph
from bucketed
group by 1, 2, 3, 4, 5, 6
order by trip_count desc