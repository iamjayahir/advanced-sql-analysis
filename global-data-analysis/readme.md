# Global Happiness & Economic Data Analysis

##  Project Overview
This project explores the relationship between national happiness scores and other macroeconomic and demographic factors like inflation and population. The analysis involves integrating data from multiple international datasets to uncover trends and correlations.

##  Dataset Description
The analysis uses the following tables:
*   `happiness_scores`: Annual happiness scores for various countries.
*   `happiness_scores_current`: Data for the most recent year (2024).
*   `country_stats`: Demographic information like `population` and `continent`.
*   `inflation_rates`: Annual inflation rates for various countries.

##  Skills & Techniques Demonstrated
*   **Complex Multi-Table Joins:** `INNER JOIN` on multiple conditions (country AND year).
*   **Window Functions:** `LAG()` for year-over-year comparisons, `NTILE()` for ranking, `ROW_NUMBER()`.
*   **Subqueries & CTEs:** Comparing country scores to regional/global averages.
*   **Set Operations:** `UNION` and `UNION ALL` to combine datasets from different years.
*   **Data Validation:** Using `LEFT JOIN...IS NULL` (anti-join) to find countries missing from secondary datasets.

##  Key Analysis Performed
1.  **Happiness-Inflation Correlation:** Joined happiness and inflation data by country and year to analyze potential relationships.
2.  **Benchmarking:** Compared each country's annual happiness score to its own historical average and the global average.
3.  **Trend Analysis:** Used `LAG()` to calculate the year-over-year change in happiness score for each country.
4.  **Regional Ranking:** Used `NTILE(4)` to identify the top 25% of happiest countries within each region for a given year.
5.  **Data Integration:** Combined historical happiness data with the most current year's data using `UNION ALL`.

##  How to Use
1.  The core SQL script is in the file: [`happiness_analysis.sql`](./happiness_analysis.sql)
2.  The queries are organized to build from simple exploration to complex analysis.
3.  Run the queries in a MySQL-compatible environment.

##  Future Enhancements
*   Statistical analysis in Python or R to quantify the correlation between happiness and other factors.
*   Creating a time-series dashboard to visualize how happiness scores have evolved globally.
