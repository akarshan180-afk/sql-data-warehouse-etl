# SQL Data Warehouse & Analytics Pipeline

An end-to-end data warehousing and analytics solution built on **SQL Server**, covering raw ingestion, ETL through a Medallion Architecture (Bronze → Silver → Gold), star-schema dimensional modeling, automated data-quality testing, and SQL-based business intelligence reporting.

**Stack:** Microsoft SQL Server · T-SQL · Star Schema · Medallion Architecture

---

## Table of Contents

- [Architecture](#architecture)
- [Dataset](#dataset)
- [Repository Structure](#repository-structure)
- [Build Order](#build-order)
- [Data Model](#data-model)
- [Data Quality Testing](#data-quality-testing)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Analytics & Key Findings](#analytics--key-findings)
- [What I Learned](#what-i-learned)
- [License](#license)

---

## Architecture

Data flows through three layers, each with a distinct contract:

| Layer | Purpose | Load Type | Object Type | Transformations |
|---|---|---|---|---|
| **Bronze** | Raw landing zone — source data stored as-is for traceability | Full load (truncate & insert) | Tables | None |
| **Silver** | Cleansed, standardized, conformed | Full load (truncate & insert) | Tables | Deduplication, null handling, type casting, value standardization, derived columns |
| **Gold** | Business-ready analytical layer | — | Views | Star-schema modeling, surrogate keys, joins, aggregation |

<!-- CONFIRM: embed your architecture diagram here if docs/ has one, e.g.: -->
<!-- ![Architecture](docs/data_architecture.png) -->

Raw CSV exports from the **ERP** and **CRM** source systems land in Bronze. Silver applies cleansing rules and resolves schema inconsistencies between the two systems. Gold exposes a star schema that analysts and BI tools query directly — no downstream consumer ever touches Bronze or Silver.

---

## Dataset

Two source systems, delivered as CSV files under `datasets/`:

| Source | Contents |
|---|---|
| **CRM** | Customer master, product master, sales transaction details |
| **ERP** | Customer demographics, location data, product category hierarchy |

<!-- CONFIRM: fill in real numbers — highest-value detail for a reader -->
- Approximate volume: `<N>` sales transactions across `<N>` customers and `<N>` products
- Time period covered: `<start year>`–`<end year>`

---

## Repository Structure

```
sql-data-warehouse-etl/
│
├── datasets/                          # Raw source CSVs (ERP and CRM exports)
│
├── docs/                              # Architecture diagrams, data catalog, naming conventions
│
├── scripts/
│   ├── init_database.sql              # Creates the DataWarehouse database and bronze/silver/gold schemas
│   │
│   ├── bronze/
│   │   ├── ddl_bronze.sql             # Table definitions for the raw layer
│   │   └── proc_load_bronze.sql       # Stored procedure to load Bronze from datasets/
│   │
│   ├── silver/
│   │   ├── ddl_silver.sql             # Table definitions for the cleansed layer
│   │   └── proc_load_silver.sql       # Stored procedure to transform Bronze -> Silver
│   │
│   ├── gold/
│   │   └── ddl_gold.sql               # View definitions for the star schema
│   │
│   └── exploratory_data_analysis/
│       ├── 00_init_database.sql       # Initializes the analytics database/schema
│       ├── data_exploration/
│       │   ├── 01_database_exploration.sql
│       │   ├── 02_dimensions_exploration.sql
│       │   ├── 03_date_range_exploration.sql
│       │   └── 04_measures_exploration.sql
│       └── data_analysis/
│           ├── 01_magnitude_analysis.sql
│           ├── 02_ranking_analysis.sql
│           ├── 03_change_over_time_analysis.sql
│           ├── 04_cumulative_analysis.sql
│           ├── 05_performance_analysis.sql
│           ├── 06_data_segmentation.sql
│           ├── 07_part_to_whole_analysis.sql
│           ├── 08_report_customers.sql        # gold.report_customers view
│           └── 09_report_products.sql         # gold.report_products view
│
├── tests/                             # Data quality validation scripts
│
├── LICENSE
└── README.md
```

---

## Build Order

The scripts are meant to be read and run in this order on a SQL Server instance:

1. **`scripts/init_database.sql`** — creates the `DataWarehouse` database and the `bronze` / `silver` / `gold` schemas.
   > ⚠️ Drops the database if it already exists — don't point this at anything you care about.
2. **`scripts/bronze/ddl_bronze.sql`** — creates the raw staging tables.
3. **`scripts/bronze/proc_load_bronze.sql`** — creates the load procedure, then run:
   ```sql
   EXEC bronze.load_bronze;
   ```
4. **`scripts/silver/ddl_silver.sql`** and **`proc_load_silver.sql`** — same pattern for Silver:
   ```sql
   EXEC silver.load_silver;
   ```
5. **`scripts/gold/ddl_gold.sql`** — creates the Gold views (`dim_customers`, `dim_products`, `fact_sales`, and the customer/product report views).
6. **`tests/`** — run the validation scripts and confirm every check returns zero rows.
7. **`scripts/exploratory_data_analysis/`** — run `00_init_database.sql` once, then work through `data_exploration/` and `data_analysis/` in numeric order against the Gold views.

<!-- CONFIRM: procedure names and object names against your actual DDL -->

---

## Data Model

Gold is a star schema: one fact table surrounded by conformed dimensions.

| Object | Type | Grain | Description |
|---|---|---|---|
| `gold.dim_customers` | Dimension | One row per customer | Customer master merged from CRM and ERP, with demographics and location |
| `gold.dim_products` | Dimension | One row per product | Product master with category hierarchy; current products only |
| `gold.fact_sales` | Fact | One row per order line | Sales transactions joined to customer and product surrogate keys |
| `gold.report_customers` | Report view | One row per customer | Consolidated customer KPIs — recency, order frequency, average order value |
| `gold.report_products` | Report view | One row per product | Consolidated product KPIs and performance metrics |

<!-- CONFIRM: object names -->

Each dimension carries a surrogate key generated in the Gold layer rather than reusing source system IDs, so the model stays stable if a source system changes its keying.

Full column-level documentation lives in `docs/`. <!-- CONFIRM: filename -->

### Naming Conventions

- Schemas mirror layers: `bronze`, `silver`, `gold`
- Bronze and Silver table names keep the source prefix (`crm_`, `erp_`) so lineage is obvious
- Gold objects use business-facing names with `dim_` / `fact_` / `report_` prefixes
- Surrogate keys end in `_key`; source system identifiers end in `_id`

---

## Data Quality Testing

The `tests/` folder holds validation scripts run after each layer loads. Every check is written to return **zero rows on success**, so a non-empty result is a failure.

Checks cover:

- **Primary key integrity** — no nulls or duplicates in dimension keys
- **Referential integrity** — every foreign key in `fact_sales` resolves to a dimension row
- **String standardization** — no unwanted leading/trailing whitespace, consistent casing in categorical fields
- **Value domains** — categorical columns contain only expected values after standardization
- **Date validity** — no out-of-range or impossible dates; order date always precedes ship and due dates
- **Derived field consistency** — `sales = quantity × price` holds for every row

<!-- CONFIRM: prune or extend to match what your scripts actually assert -->

---

## Exploratory Data Analysis

`scripts/exploratory_data_analysis/data_exploration/` profiles the Gold layer before any reporting is built:

- **`01_database_exploration.sql`** — inventory of tables and views available
- **`02_dimensions_exploration.sql`** — distinct countries, categories, and customer segments present
- **`03_date_range_exploration.sql`** — first/last order dates, span of the reporting window, customer age range
- **`04_measures_exploration.sql`** — total sales, quantity, order count, average price, distinct customer count

## Analytics & Key Findings

`scripts/exploratory_data_analysis/data_analysis/` builds outward from that profile:

| Script | Question it answers |
|---|---|
| `03_change_over_time_analysis.sql` | How do sales, order volume, and customer counts trend by month and year? |
| `04_cumulative_analysis.sql` | What does running total revenue look like over the reporting window? |
| `05_performance_analysis.sql` | How does each product compare against its own prior year and its category average? |
| `07_part_to_whole_analysis.sql` | Which categories contribute the largest share of total revenue? |
| `06_data_segmentation.sql` | How do customers and products group by spend tier, tenure, and price band? |
| `08_report_customers.sql` / `09_report_products.sql` | Consolidated KPI views — recency, average order value, monthly spend |

### Selected findings

<!-- FILL THIS IN — three concrete, numeric findings do more for this README than everything above them. Shape to follow: -->

1. `<Category X>` accounts for roughly `<N>%` of total revenue, while `<Category Y>` contributes under `<N>%` despite holding `<N>` of the product catalog.
2. `<N>%` of customers are one-time buyers; repeat customers generate `<N>×` the average lifetime revenue.
3. Revenue peaks in `<month/period>` each year, with a consistent `<N>%` lift over the annual monthly average.

---

## What I Learned

<!-- OPTIONAL but worth keeping — two or three honest sentences. Ideas to draw on: -->
- Why separating raw, cleansed, and business layers makes debugging tractable — when a number looks wrong, the layer boundaries tell you where to look.
- Why surrogate keys matter when integrating two source systems with independent keying schemes.
- Writing quality checks that fail loudly, rather than trusting a load that reports success.

**Possible next steps:** incremental loads in place of full refreshes, orchestration with SQL Agent or Airflow, and a Power BI layer on top of Gold.

---

## License

Released under the [MIT License](LICENSE). Free to use, modify, and distribute with attribution.
