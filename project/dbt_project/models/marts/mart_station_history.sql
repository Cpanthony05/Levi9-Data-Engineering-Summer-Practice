select
    station_id,
    count(*) as version_count,
    min(dbt_valid_from) as first_seen,
    max(dbt_valid_from) as last_changed,
    list(distinct station_name) as station_names_seen
from {{ ref('dim_station_snapshot') }}
group by station_id
having count(*) > 1
order by version_count desc