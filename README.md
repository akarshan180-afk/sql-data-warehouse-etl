# SQL Data Warehouse & Analytics Pipeline

An end-to-end data warehousing and analytics solution built using **SQL Server**. This project demonstrates raw data ingestion, ETL processing through a Medallion Architecture (Bronze $\rightarrow$ Silver $\rightarrow$ Gold), star-schema data modeling, and business intelligence reporting.

---

## 🚀 Project Overview & Objectives

The goal of this project is to consolidate disparate sales data from multiple source systems into a single analytical data warehouse, enabling fast, structured reporting and data-driven business decisions.

### 1. Data Engineering (Data Warehouse Build)
* **Data Sources:** Ingested transactional datasets from ERP and CRM source systems.
* **Data Quality & Cleansing:** Handled missing values, resolved schema inconsistencies, and removed duplicate records prior to modeling.
* **Integration & Architecture:** Built a structured data model (Medallion Architecture) optimized for analytical querying.
* **Documentation:** Documented schemas and transformations for downstream analytics teams and business stakeholders.

### 2. Data Analytics & Business Intelligence
Formulated SQL-based analytical queries to extract operational insights across key business areas:
* **Customer Behavior:** Tracking purchase history, customer segmentation, and interaction patterns across CRM records.
* **Product Performance:** Identifying top-performing categories, revenue drivers, and inventory velocity.
* **Sales Trends:** Aggregating historical sales performance across time dimensions to support forecasting.

---

## 🛠 Tech Stack & Architecture

* **Database Engine:** Microsoft SQL Server
* **Data Modeling:** Star Schema (Fact & Dimension Tables)
* **ETL Layers:** 
  * `Bronze`: Raw staging area for ERP & CRM source files
  * `Silver`: Cleaned, validated, and conformed datasets
  * `Gold`: Business-ready aggregation tables for analytics
* **Languages:** T-SQL

---

## 🛡 License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and distribute this code with attribution.
