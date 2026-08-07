-- models/marts/mart_station_utilization_by_hour.sql
with hourly_activity as (
    select
        start_station_id as station_id,
        extract(hour from started_at) as hour_of_day,
        member_casual,
        count(*) as departures
    from {{ ref('fct_trips') }}
    where start_station_id is not null
    group by 1, 2, 3
),

station_peak as (
    select
        station_id,
        member_casual,
        max(departures) as peak_departures
    from hourly_activity
    group by 1, 2
),

station_names as (
    select distinct station_id, station_name
    from {{ ref('dim_station_snapshot') }}
)

select
    h.station_id,
    sn.station_name,
    h.hour_of_day,
    h.member_casual,
    h.departures,
    round(100.0 * h.departures / nullif(p.peak_departures, 0), 1) as pct_of_station_peak_activity
from hourly_activity h
join station_peak p
    on h.station_id = p.station_id
    and h.member_casual = p.member_casual
left join station_names sn
    on h.station_id = sn.station_id
where h.departures >= 5
order by h.station_id, h.member_casual, h.hour_of_day