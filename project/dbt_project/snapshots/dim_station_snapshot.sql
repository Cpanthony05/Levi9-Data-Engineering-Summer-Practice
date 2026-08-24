{% snapshot dim_station_snapshot %}
{{
    config(
        target_schema='snapshots',
        unique_key='station_id',
        strategy='check',
        check_cols=['station_name', 'latitude', 'longitude'],
    )
}}
select station_id, station_name, latitude, longitude
from {{ ref('int_station_observations') }}
qualify row_number() over (partition by station_id order by observed_at desc) = 1
{% endsnapshot %}