# Procure-to-Pay Data Pipeline Emulation

A production-grade data engineering portfolio project that emulates an SAP MM (Materials Management) Procure-to-Pay data
pipeline using PostgreSQL, Python, and Apache Airflow.

## Overview

This project demonstrates end-to-end data engineering capabilities by recreating a subset of the SAP MM schema and
implementing a complete data pipeline workflow. It showcases real-world experience with:
- SAP MM domain knowledge (procurement processes, master data structures)
- Modern data engineering stack (PostgreSQL, Docker, Airflow)
- ETL/ELT pipeline development
- Data warehouse design and dimensional modeling

## Architecture

The system is organized into three distinct PostgreSQL schemas, each serving a specific purpose in the data pipeline:

### 1. Operational Schema
The transactional layer containing:
- **Real-time transaction data**: Purchase requisitions, purchase orders, goods receipts, invoices, payments
- **Master data**: Material masters, vendor masters, purchasing info records
- **Configuration data**: Plants, storage locations, purchasing organizations, company codes

Follows SAP MM naming conventions for tables (e.g., `EKKO`, `EKPO`, `EBAN`, `MARA`, `LFA1`) and fields, maintaining data
types and relationships consistent with the SAP data model.

### 2. Bootstrap Schema
The data generation and staging layer:
- **Synthetic data generation**: SQL scripts produce clean, realistic procurement data
- **Data corruption**: Intentional introduction of data quality issues (duplicates, missing values, format
inconsistencies, referential integrity violations)
- **Multi-format extraction**: Exports data to staging directory in various formats (XML, CSV, XLSX, JSON)
- **Testing scenarios**: Provides corrupted datasets to validate data cleansing and transformation logic

### 3. Warehouse Schema
The analytical layer containing:
- **Fact tables**: Aggregated procurement metrics (spend analysis, order fulfillment, invoice accuracy)
- **Dimension tables**: Time, material, vendor, purchasing organization dimensions
- **KPIs and metrics**: Procurement cycle time, PO accuracy rate, vendor performance indicators
- **Pre-aggregated views**: Optimized for reporting and analytics

### Data Flow

```
Bootstrap Schema          Staging Directory         Operational Schema         Warehouse Schema
    │                           │                          │                         │
    │ Generate synthetic data   │                          │                         │
    ├──────────────────────────>│                          │                         │
    │                           │                          │                         │
    │ Apply corruption rules    │                          │                         │
    ├──────────────────────────>│                          │                         │
    │                           │                          │                         │
    │ Export (XML/CSV/XLSX)     │                          │                         │
    ├──────────────────────────>│                          │                         │
    │                           │                          │                         │
    │                           │ Ingest & cleanse         │                         │
    │                           ├─────────────────────────>│                         │
    │                           │                          │                         │
    │                           │                          │ Transform & aggregate   │
    │                           │                          ├────────────────────────>│
    │                           │                          │                         │
    │                           │                          │    Calculate KPIs       │
    │                           │                          │<────────────────────────┤
```

All orchestration is managed by Apache Airflow DAGs that handle:
- Data generation scheduling
- File format conversions
- Data quality checks
- ETL job dependencies
- Error handling and notifications

## Technology Stack

- **Database**: PostgreSQL (multi-schema design)
- **Orchestration**: Apache Airflow
- **Language**: Python (data generation, transformations)
- **Containerization**: Docker & Docker Compose
- **Data Formats**: XML, CSV, XLSX, JSON

## Project Goals

This project serves as a portfolio demonstration for Data Engineering positions, highlighting:

1. **SAP MM Domain Expertise**: Deep understanding of procurement processes from experience as a Data Analyst in SAP MM
for telco projects
2. **ETL Development Skills**: Proven capabilities from experience as an ETL Developer working with SAS/Oracle SQL
3. **Modern Data Stack**: Proficiency with current data engineering tools and best practices
4. **Data Pipeline Design**: End-to-end pipeline implementation from source to warehouse
5. **Data Quality Engineering**: Handling real-world data quality challenges


## Installation & Setup

1. **Clone the repository**
   ```bash
   git https://github.com/stathvlach/procure-to-pay-data-pipeline.git
   cd procure-to-pay-data-pipeline
   ```

2. **Start the environment**
   ```bash
   docker-compose up -d
   ```

   This will start:
   - PostgreSQL database (port 5432)


3. **Verify installation**
   ```bash
   docker-compose exec postgres psql -U postgres -c "\dn"
   ```
   You should see the three schemas: `operational`, `bootstrap`, and `warehouse`.

## Project Structure

```
.
├── docker/
├── docs/
├── └── nano-mm-explained.md
├── sql/             # SQL scripts
│   ├── analytics/
│   ├── bootstrap/
│   ├── staging/
│   └── operational/
│
├── docker-compose.yml
├── LICENSE
├── nano_mm_erd.png
└── README.md
```

## Key Features

- ✅ **SAP MM Schema Compliance**: Accurate replication of SAP table structures and naming conventions
- ✅ **Realistic Data Generation**: Synthetic data that mirrors real procurement patterns
- ✅ **Data Quality Scenarios**: Intentional corruption for testing cleansing logic
- ✅ **Multi-format Support**: Handles XML, CSV, XLSX, JSON file formats
- ✅ **Dimensional Modeling**: Star schema design in warehouse layer
- ✅ **Orchestration**: Airflow-managed dependencies and scheduling
- ✅ **Containerized**: Fully dockerized for easy deployment

## Skills Demonstrated

**Data Engineering**
- ETL/ELT pipeline design and implementation
- Data warehouse dimensional modeling
- Data quality and validation frameworks
- Workflow orchestration with Airflow

**Database & SQL**
- PostgreSQL multi-schema architecture
- Complex SQL transformations
- Performance optimization
- Data modeling

**Domain Knowledge**
- SAP MM procurement processes
- P2P cycle understanding
- Master data management
- Procurement analytics and KPIs

**DevOps**
- Docker containerization
- Docker Compose orchestration
- Environment configuration


## License

MIT License - see LICENSE file for details

---

*This project is part of a portfolio demonstrating data engineering capabilities for professional opportunities.*
