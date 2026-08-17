# Automated Corporate Revenue Forecasting Pipeline (R)

## Project Overview
This repository features an end-to-end data pipeline built in R designed to replace manual, error-prone manual forecasting schedules. The pipeline automates the process of extracting raw ledger logs, cleansing common ERP system errors, and deploying a predictive time-series model to guide corporate financial planning.

## Key Core Competencies Demonstrated
* **Automated Data Cleansing (ETL):** Script isolates and resolves structural data discrepancies, automatically repairing data type anomalies and imputing omitted records via a localized 3-month rolling mean.
* **Predictive Modeling & Trend Analysis:** Implements a time-series Ordinary Least Squares (OLS) Linear Regression model capturing continuous long-term corporate growth trends alongside cyclical month-over-month seasonality variations.
* **Architecture Portability:** Configured purely with standalone relative pathing, ensuring the pipeline executes natively out-of-the-box in any production deployment.

## Business Impact & Outputs
The pipeline automatically outputs a structured financial cube (`fpa_automated_revenue_forecast.csv`) merging historical results with an objective 3-month forward baseline projection for executive leadership review. This infrastructure eliminates manual file consolidation time, flags budget deviations early, and equips corporate stakeholders with clean data to drive capital allocation decisions.

