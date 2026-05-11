# Procure-to-Pay Data Pipeline Emulation

A data engineering portfolio project that emulates an SAP MM (Materials Management) Procure-to-Pay data
pipeline using PostgreSQL, Python, and Apache Airflow.

## Overview

This project demonstrates data engineering capabilities by recreating a subset of the SAP MM schema and
implementing a data pipeline workflow. It showcases real-world experience with:
- SAP MM domain knowledge (procurement processes, master data structures)
- Modern data engineering stack (PostgreSQL, Docker, Airflow)
- ETL/ELT pipeline development

## Architecture

### 1. Operational Schema
The transactional layer containing:
- **Real-time transaction data**: Purchase requisitions, purchase orders, goods receipts, invoices, payments
- **Master data**: Material masters, vendor masters, purchasing info records
- **Configuration data**: Plants, storage locations, purchasing organizations, company codes

Follows SAP MM naming conventions for tables (e.g., `EKKO`, `EKPO`, `EBAN`, `MARA`, `LFA1`) and fields, maintaining data
types and relationships consistent with the SAP data model.

Please find elaborated explanation on the schema architecture in the file nano-mm-explained.md

### 2. Data Pipeline Flow

The end-to-end P2P flow is:

Vendor / Material Master Data
         ↓
Purchase Orders (EKKO / EKPO)
         ↓
Goods Receipts / Invoices (EKBE / MSEG / RSEG)

Each layer is generated sequentially with controlled dependencies and business logic constraints.

### 3. Airflow Orchestration

The pipeline is orchestrated using Apache Airflow DAGs:

operational_schema_setup ->  initializes schema and master data
populate_purchase_orders -> generates EKKO/EKPO datasets

Execution is triggered via external startup scripts:

airflow dags trigger populate_purchase_orders

## Technology Stack

- **Database**: PostgreSQL (multi-schema design)
- **Orchestration**: Apache Airflow
- **Language**: SQL, Python
- **Containerization**: Docker & Docker Compose

## Project Goals

This project serves as a portfolio demonstration for Data Engineering positions, highlighting:

1. **SAP MM Domain Expertise**: Deep understanding of procurement processes from experience as a Data Analyst in SAP MM
for telco projects
2. **ETL Development Skills**: Proven capabilities from experience as an ETL Developer working with SAS/Oracle SQL
3. **Modern Data Stack**: Proficiency with current data engineering tools and best practices

## Installation & Setup

1. **Clone the repository**
   ```bash
   git https://github.com/stathvlach/procure-to-pay-data-pipeline.git
   cd procure-to-pay-data-pipeline
   ```

2. **Start the environment**
   For linux:

   ```bash
   run_demo.sh
   ```
   For Windows:
   ```bash
   run_demo.bat
   ```
3. **Verify results**
   The run_demo script will open the airflow web monitor as well as the adminer web interface in the default web browser for your system.
   Please feel free to explore the tables of the database and the execution logs of the airflow dags

## Key Features

- **SAP MM Schema Compliance**: Accurate replication of SAP table structures and naming conventions
- **Realistic Data Generation**: Synthetic data that mirrors real procurement patterns
- **Orchestration**: Airflow-managed dependencies and scheduling
- **Containerized**: Fully dockerized for easy deployment

## Skills Demonstrated

**Data Engineering**
- ETL/ELT pipeline design and implementation
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

**DevOps**
- Docker containerization
- Docker Compose orchestration
- Environment configuration


## License

MIT License - see LICENSE file for details

---

*This project is part of a portfolio demonstrating data engineering capabilities for professional opportunities.*
