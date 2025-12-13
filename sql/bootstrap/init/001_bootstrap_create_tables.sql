-- =====================================================================
-- Project : Procure-to-Pay Data Platform
-- Layer   : bootstrap
-- Folder  : init
-- File    : 001_bootstrap_create_tables.sql
--
-- Purpose:
--   Create all bootstrap tables required to generate and manage clean and
--   corrupted transactional datasets and to configure corruption behavior.
--
-- Description:
--   This script defines the physical tables of the bootstrap schema, which
--   represents a simulated external environment. The bootstrap layer
--   generates transactional procurement documents in both "clean" and
--   "corrupted" variants for:
--     - EKKO / EKPO (Purchase Orders)
--     - MKPF / MSEG (Goods Movements)
--     - RBKP / RSEG (Invoices)
--
--   The bootstrap schema may store intermediate generated datasets (clean
--   and corrupted) to support deterministic file generation and repeatable
--   simulations. These datasets are subsequently exported as landing files
--   (CSV / JSON / XML) for ingestion by the staging layer.
--
--   In addition, this script creates the declarative configuration tables
--   that define corruption rules, their application scope per table, and
--   rule parameterization, enabling corruption behavior changes without
--   modifying generator logic.
--
-- Inputs:
--   None.
--
-- Outputs:
--   Bootstrap tables, including:
--     - Transactional generator tables (clean & corrupted variants) for:
--         - EKKO, EKPO, MKPF, MSEG, RBKP, RSEG
--     - Corruption configuration tables:
--         - bootstrap.corruption_rule
--         - bootstrap.table_corruption_config
--         - bootstrap.corruption_rule_param
--
-- Execution Context:
--   Executed during database initialization after the bootstrap schema has
--   been created. Intended to be re-runnable in development environments.
--   (Exact idempotency depends on DDL strategy used in this script.)
--
-- Notes :
--   The bootstrap schema is intentionally isolated from staging and
--   operational schemas to preserve separation of concerns:
--     - bootstrap: external simulation + landing file generation
--     - staging  : bronze/silver refinement
--     - operational: conformed system of record
--
-- Author : Stathis Vlachos
-- =====================================================================


-- Corruption rules catalog (what rules exist)
CREATE TABLE bootstrap.corruption_rule (
    rule_code     TEXT,   -- e.g. 'NULLIFY_FIELD', 'INVALID_DATE', 'DUPLICATE_KEY'
    description   TEXT,   -- human-readable description
    rule_category TEXT    -- e.g. 'NULLS', 'RANGE', 'FORMAT', 'DUPLICATES', 'REFERENTIAL'
);

-- Table-level corruption configuration (which rules apply where)
CREATE TABLE bootstrap.table_corruption_config (
    config_id     BIGINT,         -- surrogate identifier for the config row
    target_table  TEXT,           -- e.g. 'EKKO', 'EKPO', 'MKPF', 'MSEG', 'RBKP', 'RSEG'
    rule_code     TEXT,           -- references corruption_rule.rule_code (constraint in 002)
    intensity     NUMERIC(6,4),    -- e.g. 0.0500 = 5% corruption rate
    enabled       BOOLEAN         -- whether the rule is active for this table
);

-- Rule parameterization (rule-specific options per config)
CREATE TABLE bootstrap.corruption_rule_param (
    config_id    BIGINT,  -- references table_corruption_config.config_id (constraint in 002)
    param_name   TEXT,    -- e.g. 'columns', 'min', 'max', 'days_offset'
    param_value  TEXT     -- stored as text; interpreted by generator logic
);

-- EKKO – Purchasing Document Header.
-- Stores header-level information for purchase orders, such as vendor, company code, date, and currency.
CREATE TABLE bootstrap.ekko_clean (
ebeln VARCHAR(10),          -- Purchasing document number
    bukrs VARCHAR(4),       -- Company code
    lifnr VARCHAR(10),      -- Vendor
    bedat DATE,             -- Purchasing document date
    waers VARCHAR(5)        -- Currency key
);

CREATE TABLE bootstrap.ekko_corrupted (
    ebeln VARCHAR(10),      -- Purchasing document number
    bukrs VARCHAR(4),       -- Company code
    lifnr VARCHAR(10),      -- Vendor
    bedat DATE,             -- Purchasing document date
    waers VARCHAR(5)        -- Currency key
);

-- EKPO – Purchasing Document Item.
-- Stores item-level details for purchase orders, including material, plant, quantity, and pricing.
CREATE TABLE bootstrap.ekpo_clean (
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

CREATE TABLE bootstrap.ekpo_corrupted (
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
CREATE TABLE bootstrap.mkpf_clean (
    mblnr VARCHAR(10),      -- Material document number
    mjahr INTEGER,          -- Material document year
    budat DATE              -- Posting date
);

CREATE TABLE bootstrap.mkpf_corrupted (
    mblnr VARCHAR(10),      -- Material document number
    mjahr INTEGER,          -- Material document year
    budat DATE              -- Posting date
);

-- MSEG – Material Document Item.
-- Stores item-level lines of material documents, including movement type, quantity, value, and stock location.
CREATE TABLE bootstrap.mseg_clean (
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
    waers VARCHAR(5)        -- Currency
);

CREATE TABLE bootstrap.mseg_corrupted (
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
    waers VARCHAR(5)        -- Currency
);

-- RBKP – Invoice Document Header.
-- Stores header-level information for vendor invoices, including document number, vendor, dates, and currency.
CREATE TABLE bootstrap.rbkp_clean (
    belnr VARCHAR(10),      -- Invoice document number
    gjahr INTEGER,          -- Fiscal year
    bukrs VARCHAR(4),       -- Company code
    lifnr VARCHAR(10),      -- Vendor
    bldat DATE,             -- Invoice document date
    budat DATE,             -- Posting date
    waers VARCHAR(5)        -- Currency
);

CREATE TABLE bootstrap.rbkp_corrupted (
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
CREATE TABLE bootstrap.rseg_clean (
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

CREATE TABLE bootstrap.rseg_corrupted (
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
