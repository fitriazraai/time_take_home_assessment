# Chicago Taxi Trips — dbt & BigQuery Analytics Engineering Project

## 1. Overview & Objective

This repository implements an end-to-end analytics engineering pipeline using **dbt** and **Google BigQuery** on the public `bigquery-public-data.chicago_taxi_trips.taxi_trips` dataset, structured to feed downstream BI reporting in **Looker Studio**.

Because the raw data already lives in BigQuery, the pipeline prioritizes **modular SQL transformations, BigQuery scan-cost reduction via partitioning and clustering, explicit data quality tests, and clear model grain definitions**—supporting analyses such as tip and tip-per-hour performance, daily/weekly trip patterns (with Monday-first ordering), and daily shifts exceeding 16 active trip hours (`> 57,600` seconds).

---

## 2. Medallion Architecture & Materializations

```text
┌──────────────────────────────────────────────────────────┐
│ Source Layer (BigQuery Public Dataset)                   │
│ bigquery-public-data.chicago_taxi_trips.taxi_trips       │
└────────────────────────────┬─────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────┐
│ Staging Layer (Materialized: View)                       │
│ models/staging/chicago_taxi_trips/stg_chicago_taxi__trips│
│ • Type casting, snake_case renaming, date extraction     │
│ • Filters out null primary keys, start timestamps, & cabs │
└────────────────────────────┬─────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────┐
│ Intermediate Layer (Materialized: Ephemeral)             │
│ models/intermediate/taxi_trips/int_taxi_trips__enriched  │
│ • Derived metrics: trip_minutes, avg_speed_mph,          │
│   tip_to_fare_ratio, hour & Monday-first weekday fields  │
│ • 'UNKNOWN' fallbacks & anomaly flags (is_anomalous_trip)│
└────────────────────────────┬─────────────────────────────┘
                             │
              ┌──────────────┴──────────────┐
              ▼                             ▼
┌───────────────────────────┐ ┌────────────────────────────┐
│ Marts: fct_taxi_trips     │ │ Marts: mrt_daily_taxi      │
│ (Table, partitioned &     │ │ (Table, partitioned &      │
│  clustered)               │ │  clustered)                │
│ • Grain: 1 row per trip   │ │ • Grain: 1 row per         │
│ • Excludes anomalous rows │ │   taxi_id + trip_start_date│
└─────────────┬─────────────┘ └──────────────┬─────────────┘
              │                              │
              └──────────────┬───────────────┘
                             ▼
┌──────────────────────────────────────────────────────────┐
│ BI / Visualization Layer                                 │
│ Looker Studio Dashboard                                  │
└──────────────────────────────────────────────────────────┘
