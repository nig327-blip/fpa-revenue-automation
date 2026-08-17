# ==============================================================================
# FP&A PORTFOLIO PROJECT 1: AUTOMATED REVENUE FORECASTING PIPELINE
# Purpose: Demonstrates data cleaning, statistical modeling, and automated 
#          reporting to replace manual Excel-based financial forecasting.
# Author: Technical Financial Analyst Candidate
# Language: R
# Target Track: Corporate Finance / FP&A (Citi, Verizon, Pfizer, Amex)
# ==============================================================================

# ------------------------------------------------------------------------------
# STEP 1: ENVIRONMENT & PIPELINE SETUP
# ------------------------------------------------------------------------------
# Note: For an advanced portfolio, you can install 'openxlsx' and 'ggplot2'
# via install.packages(). This script leverages base R to guarantee 
# 100% runnability out of the box without external package dependencies.

cat("=== Starting Automated Revenue Forecasting Pipeline ===\n\n")

set.seed(42) # Set seed to ensure reproducible results across environments

# ------------------------------------------------------------------------------
# STEP 2: SIMULATE HISTORICAL ERP REVENUE EXTRACT (Messy Raw Data)
# ------------------------------------------------------------------------------
# Creating a 24-month timeline representing Fiscal Years 2024 and 2025
months <- seq(as.Date("2024-01-01"), as.Date("2025-12-01"), by = "month")

# Generate baseline revenue with a steady corporate growth trend
base_revenue <- seq(150000, 220000, length.out = 24)

# Create a realistic corporate seasonality multiplier (Q4 holiday/budget spikes)
seasonality <- c(0.90, 0.85, 1.00, 1.05, 1.10, 1.00, 0.95, 0.90, 1.05, 1.15, 1.30, 1.45)
historical_revenue <- base_revenue * rep(seasonality, 2) + rnorm(24, mean = 0, sd = 4000)

# Build the uncleaned data frame mimicking a raw system export
raw_erp_data <- data.frame(
  Posting_Date = months,
  Gross_Revenue = historical_revenue,
  Region = sample(c("North", "South", "East", "West"), 24, replace = TRUE),
  Status = "Posted",
  stringsAsFactors = FALSE
)

# INTENTIONAL ANOMALIES: Injecting common system errors to demonstrate ETL skills
raw_erp_data$Gross_Revenue[5] <- NA           # Missing entry error (May 2024)
raw_erp_data$Gross_Revenue[14] <- "215000.50"  # Text formatting constraint error (Feb 2025)

cat("[Data Load] Raw ERP System Extract Preview:\n")
print(head(raw_erp_data, 6))
cat("\n")

# ------------------------------------------------------------------------------
# STEP 3: AUTOMATED DATA CLEANING & ETL PIPELINE FUNCTION
# ------------------------------------------------------------------------------
clean_financial_records <- function(df) {
  cat("[ETL Pipeline] Initializing data remediation...\n")
  
  # 1. Address Type Conversions (Fixing character strings injected into numbers)
  df$Gross_Revenue <- as.numeric(df$Gross_Revenue)
  
  # 2. Impute Missing Values (Resolving the NA using a 3-month local rolling average)
  # This avoids distorting predictive models with structural zero-drops.
  na_positions <- which(is.na(df$Gross_Revenue))
  for (idx in na_positions) {
    rolling_mean <- mean(df$Gross_Revenue[(idx - 2):(idx + 1)], na.rm = TRUE)
    df$Gross_Revenue[idx] <- rolling_mean
    cat(sprintf(" -> Remediated missing value at index %d via 3-month rolling mean ($%.2f).\n", idx, rolling_mean))
  }
  
  # 3. Engineer Time Markers for Statistical Forecasting
  df$Trend_Index <- 1:nrow(df)                          # Continuous time index linear trend
  df$Month_Factor <- as.factor(format(df$Posting_Date, "%m")) # Captures cyclical monthly seasonality
  
  cat("[ETL Pipeline] Extraction, Transformation, and Data Loading Complete.\n\n")
  return(df)
}

processed_finance_data <- clean_financial_records(raw_erp_data)

# ------------------------------------------------------------------------------
# STEP 4: PREDICTIVE STATISTICAL MODELING (Revenue Forecasting)
# ------------------------------------------------------------------------------
cat("[Modeling] Fitting Time-Series Ordinary Least Squares (OLS) Model...\n")

# Model Formula: Revenue = Intercept + Beta1*(Time Trend) + Beta2*(Seasonal Factor)
revenue_model <- lm(Gross_Revenue ~ Trend_Index + Month_Factor, data = processed_finance_data)

# Display model characteristics to demonstrate statistical grasp in interviews
cat("--- Model Coefficients & Significance Diagnostics ---\n")
print(summary(revenue_model)$coefficients)
cat("\n")

# Establish parameters for the Q1 2026 Forecast Horizon
forecast_horizon <- 3
forecast_months <- seq(as.Date("2026-01-01"), as.Date("2026-03-01"), by = "month")
future_trend_indices <- (nrow(processed_finance_data) + 1):(nrow(processed_finance_data) + forecast_horizon)
future_month_factors <- as.factor(format(forecast_months, "%m"))

forecast_payload <- data.frame(
  Trend_Index = future_trend_indices,
  Month_Factor = future_month_factors
)

# Execute prediction calculation
predicted_revenue <- predict(revenue_model, newdata = forecast_payload)

# Format structured forecast output
forecast_summary <- data.frame(
  Posting_Date = forecast_months,
  Projected_Revenue = round(predicted_revenue, 2),
  Forecast_Type = "Base Case Model"
)

cat("--- Q1 2026 Strategic Financial Forecast ---\n")
print(forecast_summary)
cat("\n")

# ------------------------------------------------------------------------------
# STEP 5: UNIFIED EXPORT GENERATION FOR EXECUTIVE DASHBOARDS
# ------------------------------------------------------------------------------
# Consolidate historical actuals and future projections into a flat data output
final_reporting_cube <- data.frame(
  Calendar_Date    = c(processed_finance_data$Posting_Date, forecast_summary$Posting_Date),
  Actual_Revenue   = c(round(processed_finance_data$Gross_Revenue, 2), rep(NA, forecast_horizon)),
  Forecast_Revenue = c(rep(NA, nrow(processed_finance_data)), forecast_summary$Projected_Revenue),
  Data_Stream_Type = c(rep("Actuals", nrow(processed_finance_data)), rep("Forecast", forecast_horizon))
)

output_filename <- "fpa_automated_revenue_forecast.csv"
write.csv(final_reporting_cube, file = output_filename, row.names = FALSE)

cat(sprintf("[Export System] Master report written successfully to: '%s'\n", output_filename))
cat("Pipeline execution complete. Ready for portfolio integration.\n")
