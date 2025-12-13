-- =====================================================================
-- Project : Procure-to-Pay Data Platform
-- Layer   : staging
-- Folder  : init
-- File    : 001_staging_create_tables.sql
--
-- Purpose :
--   Create all staging bronze and silver tables required to ingest and
--   refine external transactional procurement data prior to operational load.
--
-- Description:
--   This script defines the physical tables of the staging schema, which
--   implements a medallion-style refinement layer:
--
--     - Bronze tables:
--         Raw ingested data loaded from landing files (CSV / JSON / XML),
--         typically preserving source structure with minimal transformation.
--
--     - Silver tables:
--         Cleaned and standardized representations of the same entities,
--         with type normalization, canonical formats, basic validation, and
--         deduplication applied. Silver tables do not enforce cross-table
--         referential integrity; relational constraints are applied later
--         when loading into the operational schema.
--
--   The staging schema covers the following transactional entities:
--     - EKKO / EKPO (Purchase Orders)
--     - MKPF / MSEG (Goods Movements)
--     - RBKP / RSEG (Invoices)
--
-- Inputs :
--   None.
--
-- Outputs:
--   Staging tables, including:
--     - Bronze: staging.bronze_ekko, staging.bronze_ekpo, staging.bronze_mkpf,
--              staging.bronze_mseg, staging.bronze_rbkp, staging.bronze_rseg
--     - Silver: staging.silver_ekko, staging.silver_ekpo, staging.silver_mkpf,
--              staging.silver_mseg, staging.silver_rbkp, staging.silver_rseg
--
-- Execution Context:
--   Executed during database initialization after the staging schema has
--   been created. The script is intended to be re-runnable in development
--   environments. (Exact idempotency depends on DDL strategy used.)
--
-- Notes :
--   - Bronze tables should include ingestion metadata fields (e.g. source_file,
--     ingest_ts) to support auditability and replay.
--   - Silver tables should remain constraint-light; apply data quality rules
--     via transformation logic rather than FK enforcement at this stage.
--
-- Author : Stathis Vlachos
-- =====================================================================


-- EKKO – Purchasing Document Header.
-- Stores header-level information for purchase orders, such as vendor, company code, date, and currency.
CREATE TABLE staging.bronze_ekko (
ebeln VARCHAR(10),          -- Purchasing document number
    bukrs VARCHAR(4),       -- Company code
    lifnr VARCHAR(10),      -- Vendor
    bedat DATE,             -- Purchasing document date
    waers VARCHAR(5),        -- Currency key
    source_file TEXT,
    ingest_ts TIMESTAMP
);

CREATE TABLE staging.silver_ekko (
    ebeln VARCHAR(10),      -- Purchasing document number
    bukrs VARCHAR(4),       -- Company code
    lifnr VARCHAR(10),      -- Vendor
    bedat DATE,             -- Purchasing document date
    waers VARCHAR(5)        -- Currency key
);

-- EKPO – Purchasing Document Item.
-- Stores item-level details for purchase orders, including material, plant, quantity, and pricing.
CREATE TABLE staging.bronze_ekpo (
    ebeln VARCHAR(10),      -- PO number
    ebelp INTEGER,          -- PO item number
    matnr VARCHAR(40),      -- Material
    werks VARCHAR(4),       -- Plant
    menge NUMERIC(13,3),    -- Order quantity
    meins VARCHAR(3),       -- Order unit
    netpr NUMERIC(11,2),    -- Net price (per price unit)
    peinh NUMERIC(5,0),     -- Price unit
    netwr NUMERIC(15,2),    -- Net item value
    source_file TEXT,
    ingest_ts TIMESTAMP
);

CREATE TABLE staging.silver_ekpo (
    ebeln VARCHAR(10),      -- PO number
    ebelp INTEGER,          -- PO item number
    matnr VARCHAR(40),      -- Material
    werks VARCHAR(4),       -- Plant
    menge NUMERIC(13,3),    -- Order quantity
    meins VARCHAR(3),       -- Order unit
    netpr NUMERIC(11,2),    -- Net price (per price unit)
    peinh NUMERIC(5,0),     -- Price unit
    netwr NUMERIC(15,2)     -- Net item value
);

-- MKPF – Material Document Header.
-- Stores header-level information for material documents such as document number, year, and posting date.
CREATE TABLE staging.bronze_mkpf (
    mblnr VARCHAR(10),      -- Material document number
    mjahr INTEGER,          -- Material document year
    budat DATE,             -- Posting date
    source_file TEXT,
    ingest_ts TIMESTAMP
);

CREATE TABLE staging.silver_mkpf (
    mblnr VARCHAR(10),      -- Material document number
    mjahr INTEGER,          -- Material document year
    budat DATE              -- Posting date
);

-- MSEG – Material Document Item.
-- Stores item-level lines of material documents, including movement type, quantity, value, and stock location.
CREATE TABLE staging.bronze_mseg (
    mblnr VARCHAR(10),      -- Material document number
    mjahr INTEGER,          -- Material document year
    zeile INTEGER,          -- Item in material document
    matnr VARCHAR(40),      -- Material
    werks VARCHAR(4),       -- Plant
    lgort VARCHAR(4),       -- Storage location
    kostl VARCHAR(10),      -- Cost center
    bwart VARCHAR(3),       -- Movement type
    menge NUMERIC(13,3),    -- Quantity
    meins VARCHAR(3),       -- Unit of measure
    dmbtr NUMERIC(15,2),    -- Amount in local currency
    waers VARCHAR(5),       -- Currency
    source_file TEXT,
    ingest_ts TIMESTAMP
);

CREATE TABLE staging.silver_mseg (
    mblnr VARCHAR(10),      -- Material document number
    mjahr INTEGER,          -- Material document year
    zeile INTEGER,          -- Item in material document
    matnr VARCHAR(40),      -- Material
    werks VARCHAR(4),       -- Plant
    lgort VARCHAR(4),       -- Storage location
    kostl VARCHAR(10),      -- Cost center
    bwart VARCHAR(3),       -- Movement type
    menge NUMERIC(13,3),    -- Quantity
    meins VARCHAR(3),       -- Unit of measure
    dmbtr NUMERIC(15,2),    -- Amount in local currency
    waers VARCHAR(5),       -- Currency
);

-- RBKP – Invoice Document Header.
-- Stores header-level information for vendor invoices, including document number, vendor, dates, and currency.
CREATE TABLE staging.bronze_rbkp (
    belnr VARCHAR(10),      -- Invoice document number
    gjahr INTEGER,          -- Fiscal year
    bukrs VARCHAR(4),       -- Company code
    lifnr VARCHAR(10),      -- Vendor
    bldat DATE,             -- Invoice document date
    budat DATE,             -- Posting date
    waers VARCHAR(5),       --
    source_file TEXT,
    ingest_ts TIMESTAMP
);

CREATE TABLE staging.silver_rbkp (
    belnr VARCHAR(10),      -- Invoice document number
    gjahr INTEGER,          -- Fiscal year
    bukrs VARCHAR(4),       -- Company code
    lifnr VARCHAR(10),      -- Vendor
    bldat DATE,             -- Invoice document date
    budat DATE,             -- Posting date
    waers VARCHAR(5)        -- Currency
);


-- RSEG – Invoice Document Item.
-- Stores item-level invoice data, linking PO items to invoiced quantities and amounts.
CREATE TABLE staging.bronze_rseg (
    belnr VARCHAR(10),      -- Invoice document number
    gjahr INTEGER,          -- Fiscal year
    buzei INTEGER,          -- Invoice line item
    ebeln VARCHAR(10),      -- PO number
    ebelp INTEGER,          -- PO item
    matnr VARCHAR(40),      -- Material
    menge NUMERIC(13,3),    -- Invoiced quantity
    meins VARCHAR(3),       -- Unit of measure
    wrbtr NUMERIC(15,2),    -- Amount in document currency
    source_file TEXT,
    ingest_ts TIMESTAMP
);

CREATE TABLE staging.silver_rseg (
    belnr VARCHAR(10),      -- Invoice document number
    gjahr INTEGER,          -- Fiscal year
    buzei INTEGER,          -- Invoice line item
    ebeln VARCHAR(10),      -- PO number
    ebelp INTEGER,          -- PO item
    matnr VARCHAR(40),      -- Material
    menge NUMERIC(13,3),    -- Invoiced quantity
    meins VARCHAR(3),       -- Unit of measure
    wrbtr NUMERIC(15,2)     -- Amount in document currency
);
