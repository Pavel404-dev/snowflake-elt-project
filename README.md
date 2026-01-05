# 🏢 Commercial Real Estate (CRE) Analytics: ELT & DWH Project

## 1. Introduction & Source Data Description
### Project Overview
The goal of this project is to build a robust **Data Warehouse (DWH)** and **ELT pipeline** in Snowflake using **Commercial Real Estate (CRE)** data. We selected the **CompStak** dataset from the Snowflake Marketplace because it provides high-quality, real-world data on lease transactions, which is essential for market analysis.

### Business Process
This project supports the **Leasing Management & Market Analysis** process. It allows real estate brokers, appraisers, and investors to:
* Monitor rental rates per square foot across different markets.
* Compare building performance based on their class (Class A vs. Class B).
* Analyze lease cycles and tenant movements.

### Source Tables
* **LEASE_COMPS**: Contains transactional data including rent prices, lease terms, execution dates, and tenant names.
* **PROPERTIES**: Contains metadata about buildings, such as year built, total square footage, building class, and specific address details.

### ERD (Entity Relationship Diagram)
The original source data from CompStak follows a normalized structure focused on property-to-lease relationships.

> **Note:**  
> *(Upload your original structure diagram to the /img folder and link it here)*

---

## 2. Dimensional Model Design
We implemented a **Star Schema** to optimize query performance and simplify data analysis for business users.



[Image of Star Schema]


### Fact Table
* **FACT_LEASES**:
    * **PK**: `LEASE_ID`
    * **FKs**: `PROPERTY_KEY`, `LOCATION_KEY`, `TENANT_KEY`, `DATE_KEY`
    * **Metrics**: `RENT_PER_SQFT`, `LEASE_TERM_MONTHS`, `TOTAL_SQFT`.
    * **Window Functions**: 
        1. `RANK()`: Used to rank leases by price within each city.
        2. `AVG() OVER()`: Used to calculate the average market rent to compare individual deals against the market.

### Dimensions
| Table | Description | SCD Type |
|-------|-------------|----------|
| **DIM_PROPERTY** | Building characteristics (Class, Year Built, Type). | **Type 1** (Updates reflect current building status). |
| **DIM_LOCATION** | Geographical hierarchy (City, State, Zip). | **Type 0** (Geography remains static). |
| **DIM_TENANT** | Tenant/Company information. | **Type 1** (Current company names). |
| **DIM_DATE** | Calendar attributes (Quarter, Month, Year). | **Type 0** (Static). |

---

## 3. ELT Process in Snowflake

### 📥 Extract
Data is pulled directly from the **Snowflake Marketplace** into a staging environment.
```sql
CREATE OR REPLACE TABLE CRE_DWH.STAGING.STG_LEASE_COMPS AS
SELECT * FROM COMPSTAK_CRE_DATA.PUBLIC.LEASE_COMPS;

CREATE OR REPLACE TABLE CRE_DWH.STAGING.STG_PROPERTIES AS
SELECT * FROM COMPSTAK_CRE_DATA.PUBLIC.PROPERTIES;
