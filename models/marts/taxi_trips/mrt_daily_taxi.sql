{{
    config(
        materialized='table',
        partition_by={
            'field': 'trip_start_date',
            'data_type': 'date',
            'granularity': 'day'
        },
        cluster_by=['taxi_id']
    )
}}

with trips as (

    select *
    from {{ ref('fct_taxi_trips') }}

),

daily_cab as (

    select
        taxi_id,
        trip_start_date,
        any_value(company_name) as company_name,
        count(distinct trip_id) as total_trips,
        sum(trip_seconds) as total_trip_seconds,
        round(sum(trip_seconds) / 3600.0, 2) as total_trip_hours,
        round(sum(tip_usd), 2) as total_tip_usd,
        case
            when sum(trip_seconds) > 0
                then round(sum(tip_usd) / (sum(trip_seconds) / 3600.0), 2)
            else null
        end as tip_per_trip_hour_usd,
        sum(trip_total_usd) as total_revenue_usd,
        sum(trip_seconds) > 57600 as is_overworked_shift
    from trips
    group by
        taxi_id,
        trip_start_date

)

select * from daily_cab
