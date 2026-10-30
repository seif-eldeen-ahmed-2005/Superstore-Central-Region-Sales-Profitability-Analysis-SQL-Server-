# 🛒 Superstore Central Region Sales & Profitability Analysis (SQL Server)

An enterprise-grade SQL Server data warehouse and advanced analytics project designed to evaluate sales performance, profit margins, product categories, and regional operational leakages for Superstore's Central Region.

---

## 📊 Project Overview
This project transforms raw retail transaction records into a structured Star Schema database in SQL Server. By utilizing advanced T-SQL queries (CTEs, Window Functions, Aggregations, and Conditional Logic), the analysis identifies key financial drivers, profitability bottlenecks, and strategic growth opportunities across products, customer segments, and states.

---

## 🚀 Key Performance Indicators (KPIs)

- **Total Sales:** **$501,239.77** across all transactions.
- **Total Profit:** **$39,706.08** resulting in an aggregate **Profit Margin of 7.92%**.
- **Order & Unit Volume:** **1,175 Total Orders** spanning **8,780 Units Sold**.
- **Customer Footprint:** **629 Unique Customers** with an average spend of **$796.88 per Customer**.
- **Order Efficiency:** Average sales of **$426.59 per Order** and **$33.79 Profit per Order**.

---

## 📈 Dashboard & Technical Architecture Preview

### 1. Database Schema & Star Schema Diagram
![Database Schema Diagram](QueryResultScreenshots/Schema.png)

### 2. Product Ranking Within Each Category (CTEs & RANK Window Function)
![Product Ranking Execution](Images/13.png)

### 3. Categorizing States by Performance (Window Functions & CASE Expressions)
![State Sales Categorization Execution](Images/14.png)

### 4. Core KPI Calculation Query
![KPI Query Execution](Images/15.png)

---

## 🛠️ Tools & SQL Concepts Used

- **Database Engine:** Microsoft SQL Server & SQL Server Management Studio (SSMS)
- **Data Modeling:** Star Schema Design, Primary Key & Foreign Key Referential Integrity Constraints
- **T-SQL Techniques:**
  - Data Definition Language (DDL) & Data Manipulation Language (DML)
  - Common Table Expressions (CTEs) & Window Functions (`RANK() OVER ()`, `AVG() OVER ()`)
  - Multi-table `INNER JOIN` & `LEFT JOIN` operations
  - Dynamic Aggregations (`SUM`, `COUNT DISTINCT`, `AVG`) & Filter Grouping (`GROUP BY`, `HAVING`)
  - Conditional Business Logic (`CASE WHEN`)

---

## 💡 Key Business Insights & Strategic Recommendations

- **Texas Profit Leakage:** Texas leads all states in raw top-line sales (**$170,187.93**), yet operates at a net loss of **-$25,729.46** due to aggressive discounting and high fulfillment costs.
- **Top Product Loss-Leaders:** Top-selling items such as the *GBC DocuBind P400 Electric Binding System* generate high revenue (**$8,710.33**), but suffer severe profit drains (**-$3,048.62**).
- **Segment Profit Disconnect:** The *Consumer* segment drives the highest total revenue (**$252,031.40**), but yields significantly lower net profits (**$8,563.86**) compared to *Corporate* (**$18,703.79**) and *Home Office* (**$12,438.43**).
- **Actionable Steps:**
  1. Implement automated discount guardrails on high-turnover loss-leader products.
  2. Conduct a logistics audit in Texas and Illinois to convert high volume into positive cash flow.
  3. Reallocate marketing budgets toward Corporate and Home Office segments for higher margin conversion.
