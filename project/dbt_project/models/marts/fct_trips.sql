-- models/marts/fct_trips.sql
{{
    config(
        materialized='incremental',
        unique_key='ride_id',
        incremental_strategy='merge'
    )
}}

with start_matches as (
    select
        t.ride_id,
        ss.station_id as start_station_id,
        ss.station_name as start_station_name,
        row_number() over (partition by t.ride_id order by ss.dbt_valid_from asc) as rn
    from {{ ref('stg_trips') }} t
    join {{ ref('dim_station_snapshot') }} ss
        on t.start_station_id = ss.station_id
        and (t.started_at < ss.dbt_valid_to or ss.dbt_valid_to is null)
),

end_matches as (
    select
        t.ride_id,
        es.station_id as end_station_id,
        es.station_name as end_station_name,
        row_number() over (partition by t.ride_id order by es.dbt_valid_from asc) as rn
    from {{ ref('stg_trips') }} t
    join {{ ref('dim_station_snapshot') }} es
        on t.end_station_id = es.station_id
        and (t.ended_at < es.dbt_valid_to or es.dbt_valid_to is null)
)

select
    t.ride_id,
    t.rideable_type,
    t.started_at,
    t.ended_at,
    t.trip_duration_seconds,
    t.member_casual,
    t.load_month,
    sm.start_station_id,
    sm.start_station_name,
    em.end_station_id,
    em.end_station_name
from {{ ref('stg_trips') }} t
left join start_matches sm on t.ride_id = sm.ride_id and sm.rn = 1
left join end_matches em on t.ride_id = em.ride_id and em.rn = 1

{% if is_incremental() %}
where t.started_at > (select max(started_at) from {{ this }})
{% endif %}