with source as (

    select *
    from {{ source('chicago_taxi_trips', 'taxi_trips') }}

),

cleaned as (

    select
        unique_key as trip_id,
        taxi_id,
        timestamp(trip_start_timestamp) as trip_start_at,
        timestamp(trip_end_timestamp) as trip_end_at,
        date(trip_start_timestamp) as trip_start_date,
        cast(trip_seconds as int64) as trip_seconds,
        cast(trip_miles as float64) as trip_miles,
        cast(pickup_census_tract as int64) as pickup_census_tract,
        cast(dropoff_census_tract as int64) as dropoff_census_tract,
        cast(pickup_community_area as int64) as pickup_community_area,
        cast(dropoff_community_area as int64) as dropoff_community_area,
        cast(fare as float64) as fare_usd,
        cast(tips as float64) as tip_usd,
        cast(tolls as float64) as tolls_usd,
        cast(extras as float64) as extras_usd,
        cast(trip_total as float64) as trip_total_usd,
        nullif(trim(upper(payment_type)), '') as payment_type,
        nullif(trim(company), '') as company_name,
        cast(pickup_latitude as float64) as pickup_latitude,
        cast(pickup_longitude as float64) as pickup_longitude,
        pickup_location,
        cast(dropoff_latitude as float64) as dropoff_latitude,
        cast(dropoff_longitude as float64) as dropoff_longitude,
        dropoff_location
    from source
    where unique_key is not null
      and trip_start_timestamp is not null
      and taxi_id is not null

)

select * from cleaned
