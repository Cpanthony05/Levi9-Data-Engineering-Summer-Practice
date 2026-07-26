-- models/intermediate/int_trips_enriched.sql
select
    t.*,
    pu.borough as pickup_borough,
    pu.zone as pickup_zone,
    dof.borough as dropoff_borough,
    dof.zone as dropoff_zone
from {{ ref('int_trips_unioned') }} t
left join {{ ref('stg_taxi_zone_lookup') }} pu
    on t.pickup_location_id = pu.location_id
left join {{ ref('stg_taxi_zone_lookup') }} dof
    on t.dropoff_location_id = dof.location_id