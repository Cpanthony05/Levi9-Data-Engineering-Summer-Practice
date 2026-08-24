-- models/marts/mart_monthly_trends.sql
with monthly as (
    select
        load_month,
        member_casual,
        count(*) as trips,
        avg(trip_duration_seconds) filter (
            where trip_duration_seconds between 0 and 86400
        ) as avg_duration_seconds
    from {{ ref('fct_trips') }}
    group by 1, 2
),
monthly_totals as (
    select load_month, sum(trips) as total_trips
    from monthly
    group by 1
)
select
    m.load_month,
    m.member_casual,
    m.trips,
    round(100.0 * m.trips / t.total_trips, 1) as pct_of_month,
    round(m.avg_duration_seconds, 1) as avg_duration_seconds
from monthly m
join monthly_totals t on m.load_month = t.load_month
order by m.load_month, m.member_casual