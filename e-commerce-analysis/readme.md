# E-Commerce & Product Analysis

##  Project Overview
This project involves analyzing an e-commerce database to solve business problems related to sales, customer behavior, and product strategy. The goal is to derive actionable insights that can drive decision-making for marketing, sales, and inventory management.

##  Dataset Description
The analysis is performed on a relational database with the following key tables:
*   `orders`: Contains transaction details like `order_id`, `customer_id`, `product_id`, `units`, and `order_date`.
*   `products`: Contains product information like `product_id`, `product_name`, `unit_price`, `factory`, and `division`.
*   `customers`: (Assumed) Contains customer demographic information.

##  Skills & Techniques Demonstrated
*   **Advanced Joins:** `LEFT JOIN` for anti-joins, `CROSS JOIN`/Self-Join for product price comparison.
*   **Window Functions:** `ROW_NUMBER()`, `DENSE_RANK()`, `NTILE()`, `LAG()`.
*   **Common Table Expressions (CTEs):** Breaking down complex queries into logical steps.
*   **Aggregation & Grouping:** `GROUP BY`, `HAVING`, `SUM`, `AVG`.
*   **Business Analysis:** Customer segmentation, product affinity analysis, pricing strategy.

##  Key Analysis Performed
1.  **Customer Segmentation:** Identified the top 1% of customers by total spending using `NTILE(100)`.
2.  **Product Analysis:**
    *   Found products with no orders (using `LEFT JOIN...IS NULL`).
    *   Identified products with similar pricing (within $0.25) using a creative self-join.
    *   Calculated how much each product's price differs from the average.
3.  **Purchase Behavior:** Analyzed the change (`LAG()`) in the number of units a customer ordered from one purchase to the next.
4.  **Data Cleaning:** Used `REPLACE()` and `COALESCE()` to handle inconsistent text and NULL values in product data.

##  How to Use
1.  The core SQL script is in the file: [`ecommerce_queries.sql`](./ecommerce_queries.sql)
2.  Each query is commented with the business problem it solves.
3.  Run the queries in a MySQL-compatible environment to recreate the analysis.

## 🚀 Future Enhancements
*   Connect the database to a BI tool (e.g., Tableau, Power BI) to build interactive dashboards.
*   Develop stored procedures for automated reporting on key metrics.
