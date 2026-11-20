# Chicago Taxi Trips — dbt & BigQuery Analytics Engineering Project

## 1. Overview & Objective

This repository outlines an end-to-end analytics engineering pipeline built with **dbt (Data Build Tool)** and **Google BigQuery**, transforming the public `bigquery-public-data.chicago_taxi_trips.taxi_trips` dataset into an analytics-ready data model designed for downstream visualization in **Looker Studio**.

Because the source dataset already resides in BigQuery rather than arriving via raw API ingestion, this architecture focuses on **modular SQL transformations, BigQuery query cost optimization (partitioning and clustering), explicit data quality testing, and clear business grain definitions**.

> **Project Scope Note:** This repository represents the architectural design, SQL transformation logic, YAML schema documentation, and test suite prepared for execution against BigQuery and Looker Studio.

---

## 2. Data Architecture & Layering Strategy

Even though `taxi_trips` is a single source table at the trip grain (`unique_key`), separating transformations into **Staging → Intermediate → Marts** ensures clear lineage, prevents duplicated business logic, and keeps downstream BI queries fast and predictable.

```text
┌──────────────────────────────────────────────────────────┐
│ Source Layer (BigQuery Public Dataset)                   │
│ bigquery-public-data.chicago_taxi_trips.taxi_trips       │
└────────────────────────────┬─────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────┐
│ Staging Layer (Materialized: View)                       │
│ stg_chicago_taxi__trips                                  │
│ • Type casting, snake_case renaming, date extraction     │
│ • Filters out null primary keys / start timestamps       │
└────────────────────────────┬─────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────┐
│ Intermediate Layer (Materialized: Ephemeral)             │
│ int_taxi_trips__enriched                                 │
│ • Derived metrics: trip_minutes, avg_speed_mph,          │
│   tip_to_fare_ratio, hour/day-of-week parts              │
│ • Standardized fallbacks ('UNKNOWN') & anomaly flags     │
└────────────────────────────┬─────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────┐
│ Marts Layer (Materialized: Partitioned & Clustered Table)│
│ fct_taxi_trips                                           │
│ • Partitioned by trip_start_date (DAY)                   │
│ • Clustered by payment_type, company_name,               │
│   pickup_community_area                                  │
│ • Excludes anomalous trip records                        │
└────────────────────────────┬─────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────┐
│ BI / Visualization Layer                                 │
│ Looker Studio Dashboard                                  │
└──────────────────────────────────────────────────────────┘
