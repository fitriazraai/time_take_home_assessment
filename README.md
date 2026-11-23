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
```
---

## 3. Chicago Taxi Analysis

**Question 1 - Top 100 Tip Earners**

Taxi-id was ranked based on total tips earned in 2022. Additional view of tips/hour gives insight on which taxi riders are most efficient in their tip capabilities

No actionable insights but suggest to expand analysis to include:
1. Tips per area - to determine high tip areas
2. Tips per payment type - to which payment type results in higher tips (probably due to ease of paying extra)




**Question 2 - Top 100 Overworkers**

Taxi_id was ranked based on total number of daily shifts where daily shifts exceed 16 hours (using trip duration as proxy)

No actionable insights but suggest to expand analysis to include:
1. Distribution of Total Trip Distances by Taxi_id - to ensure customers are shared more equally across taxi base to maintain taxi happiness




**Question 3 - Seasonal Impact on Taxi Demand**

2022 data is insufficient to make a judgement on this.
However, it is clear that Weekdays have significantly higher demand than Weekends

As such, proposed to strategize taxi shifts by optimizing shifts based on peak demand days




**Question 4 - Hourly Taxi Demand**

Peak demand is during evening rush hour while demand is least during the early mornings

As such, proposed to strategize taxi shifts by optimizing shifts based on peak demand hours




**Question 5 - Preferred Payment Types**

Credit Card is the most preferred payment option

As such, proposed to enforce taxi drivers to adopti credit card-friendly payment options for streamlined payment process and promote safety

