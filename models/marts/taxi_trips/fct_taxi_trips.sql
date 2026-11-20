{{
    config(
        materialized='table',
        partition_by={
            'field': 'trip_start_date',
            'data_type': 'date',
            'granularity': 'day'
        },
        cluster_by=['payment_type', 'company_name', 'pickup_community_area']
    )
}}

with enriched_trips as (

    select *
    from {{ ref('int_taxi_trips__enriched') }}

)

select
    trip_id,
    taxi_id,
    trip_start_at,
    trip_end_at,
    trip_start_date,
    trip_start_hour,
    trip_start_day_of_week,
    payment_type,
    company_name,
    pickup_community_area,
    dropoff_community_area,
    pickup_census_tract,
    dropoff_census_tract,
    has_pickup_community_area,
    has_dropoff_community_area,
    trip_seconds,
    trip_minutes,
    trip_miles,
    avg_speed_mph,
    fare_usd,
    tip_usd,
    tolls_usd,
    extras_usd,
    trip_total_usd,
    tip_to_fare_ratio,
    is_anomalous_trip,
    pickup_latitude,
    pickup_longitude,
    pickup_location,
    dropoff_latitude,
    dropoff_longitude,
    dropoff_location
from enriched_trips
where not is_anomalous_trip
