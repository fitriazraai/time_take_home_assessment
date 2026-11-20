with staged_trips as (

    select *
    from {{ ref('stg_chicago_taxi__trips') }}

),

enriched as (

    select
        trip_id,
        taxi_id,
        trip_start_at,
        trip_end_at,
        trip_start_date,
        extract(hour from trip_start_at) as trip_start_hour,
        extract(dayofweek from trip_start_at) as trip_start_day_of_week,
        coalesce(trip_seconds, 0) as trip_seconds,
        round(coalesce(trip_seconds, 0) / 60.0, 2) as trip_minutes,
        coalesce(trip_miles, 0.0) as trip_miles,
        case
            when trip_seconds > 0 and trip_miles >= 0
                then round(trip_miles / (trip_seconds / 3600.0), 2)
            else null
        end as avg_speed_mph,
        pickup_census_tract,
        dropoff_census_tract,
        pickup_community_area,
        dropoff_community_area,
        coalesce(pickup_community_area is not null, false) as has_pickup_community_area,
        coalesce(dropoff_community_area is not null, false) as has_dropoff_community_area,
        coalesce(fare_usd, 0.0) as fare_usd,
        coalesce(tip_usd, 0.0) as tip_usd,
        coalesce(tolls_usd, 0.0) as tolls_usd,
        coalesce(extras_usd, 0.0) as extras_usd,
        coalesce(trip_total_usd, 0.0) as trip_total_usd,
        case
            when coalesce(fare_usd, 0.0) > 0
                then round(coalesce(tip_usd, 0.0) / fare_usd, 4)
            else null
        end as tip_to_fare_ratio,
        coalesce(payment_type, 'UNKNOWN') as payment_type,
        coalesce(company_name, 'UNKNOWN') as company_name,
        pickup_latitude,
        pickup_longitude,
        pickup_location,
        dropoff_latitude,
        dropoff_longitude,
        dropoff_location,
        case
            when trip_seconds < 0
                or trip_miles < 0
                or trip_total_usd < 0
                or (trip_end_at is not null and trip_end_at < trip_start_at)
                then true
            else false
        end as is_anomalous_trip
    from staged_trips

)

select * from enriched
