with monthly as (
    select
        date_trunc('month', started_at) as trip_month,
        member_casual,
        count(*) as trips,
        avg(trip_duration_seconds) as avg_duration_seconds
    from {{ ref('fct_trips') }}
    group by 1, 2
),
monthly_totals as (
    select trip_month, sum(trips) as total_trips
    from monthly
    group by 1
)
select
    m.trip_month,
    m.member_casual,
    m.trips,
    round(100.0 * m.trips / t.total_trips, 1) as pct_of_month,
    round(m.avg_duration_seconds, 1) as avg_duration_seconds
from monthly m
join monthly_totals t on m.trip_month = t.trip_month
order by m.trip_month, m.member_casual