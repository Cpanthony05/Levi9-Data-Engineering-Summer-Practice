with aggregated as (
    select
        cab_type,
        pickup_borough,
        pickup_zone,
        date_trunc('month', pickup_datetime) as trip_month,
        count(*) as total_trips,
        sum(trip_distance) as total_distance,
        sum(fare_amount) as total_fare,
        sum(tip_amount) as total_tips
    from {{ ref('int_trips_enriched') }}
    group by 1, 2, 3, 4
)

select
    {{ dbt_utils.generate_surrogate_key(['cab_type', 'pickup_borough', 'pickup_zone', 'trip_month']) }} as trip_id,
    *
from aggregated