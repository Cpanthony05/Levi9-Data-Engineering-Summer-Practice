-- models/marts/fct_trips.sql
{{
    config(
        materialized='incremental',
        unique_key='ride_id',
        incremental_strategy='merge'
    )
}}

select
    t.ride_id,
    t.rideable_type,
    t.started_at,
    t.ended_at,
    t.trip_duration_seconds,
    t.member_casual,
    ss.station_id as start_station_id,
    ss.station_name as start_station_name,
    es.station_id as end_station_id,
    es.station_name as end_station_name
from {{ ref('stg_trips') }} t
left join {{ ref('dim_station_snapshot') }} ss
    on t.start_station_id = ss.station_id
    and (t.started_at < ss.dbt_valid_to or ss.dbt_valid_to is null)
    and t.started_at >= (
        select min(dbt_valid_from) from {{ ref('dim_station_snapshot') }} s2
        where s2.station_id = ss.station_id
    )
left join {{ ref('dim_station_snapshot') }} es
    on t.end_station_id = es.station_id
    and (t.ended_at < es.dbt_valid_to or es.dbt_valid_to is null)
    and t.ended_at >= (
        select min(dbt_valid_from) from {{ ref('dim_station_snapshot') }} s2
        where s2.station_id = es.station_id
    )

{% if is_incremental() %}
where t.started_at > (select max(started_at) from {{ this }})
{% endif %}