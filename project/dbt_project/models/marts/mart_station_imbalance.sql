with departures as (
    select start_station_id as station_id, member_casual,
           date_trunc('day', started_at) as trip_date, count(*) as departures
    from {{ ref('fct_trips') }}
    where start_station_id is not null
      and isodow(started_at) between 1 and 5  -- Mon-Fri
    group by 1, 2, 3
),
arrivals as (
    select end_station_id as station_id, member_casual,
           date_trunc('day', ended_at) as trip_date, count(*) as arrivals
    from {{ ref('fct_trips') }}
    where end_station_id is not null
      and isodow(ended_at) between 1 and 5
    group by 1, 2, 3
),
combined as (
    select
        coalesce(d.station_id, a.station_id) as station_id,
        coalesce(d.member_casual, a.member_casual) as member_casual,
        coalesce(d.trip_date, a.trip_date) as trip_date,
        coalesce(d.departures, 0) as departures,
        coalesce(a.arrivals, 0) as arrivals
    from departures d
    full outer join arrivals a
        on d.station_id = a.station_id
        and d.member_casual = a.member_casual
        and d.trip_date = a.trip_date
)
select
    c.station_id,
    sn.station_name,
    c.member_casual,
    round(avg(c.departures), 2) as avg_weekday_departures,
    round(avg(c.arrivals), 2) as avg_weekday_arrivals,
    round(avg(c.arrivals - c.departures), 2) as avg_net_imbalance
from combined c
left join (select distinct station_id, station_name from {{ ref('dim_station_snapshot') }}) sn
    on sn.station_id = c.station_id
group by 1, 2, 3
order by avg_net_imbalance