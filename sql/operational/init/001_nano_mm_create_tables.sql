-- =====================================================================
-- Project : nano-mm
-- File    : 01_nano_mm_create_tables.sql
-- Purpose : Create all core tables in the nano_mm schema
--           (master data + transactional structures).
--
-- Description:
--   This script defines the full set of operational tables that form the
--   nano_mm data model inspired by SAP MM (Materials Management).
--   It includes:
--     - Master data entities (company codes, plants, vendors, materials)
--     - Procurement process tables (purchase orders, goods receipts,
--       invoices, related history)
--     - Supporting reference/relationship tables
--
--   These tables provide the foundational operational layer from which
--   downstream ETL processes and analytical models will consume data.
--
-- Notes:
--   - Primary/foreign keys, unique constraints and indexes are created
--     in subsequent scripts (e.g. 02_nano_mm_create_constraints.sql).
--   - Table definitions are designed to be safely re-runnable where
--     possible during container initialization.
--
-- Execution context:
--   Automatically executed by Postgres via /docker-entrypoint-initdb.d
--   during database setup.
--
-- Author  : Stathis Vlachos
-- =====================================================================

SET search_path TO nano_mm;

-- T001 – Company Codes (SAP standard customizing table).
-- Represents independent legal accounting entities that structure all procurement,
-- valuation, and financial integration in the nano-mm schema.
CREATE TABLE t001 (
    bukrs VARCHAR(4)  PRIMARY KEY,  -- Company code
    butxt VARCHAR(50) NOT NULL,     -- Company code name
    land1 VARCHAR(3)  NOT NULL,     -- Country key
    waers VARCHAR(5)  NOT NULL      -- Company code currency
);

-- T001W – Plants (organizational units representing physical or logical locations).
-- Stores plant master data used for procurement, inventory management, and valuation layers.
CREATE TABLE t001w (
    werks VARCHAR(4)  PRIMARY KEY,  -- Plant
    name1 VARCHAR(30) NOT NULL,     -- Plant name
    land1 VARCHAR(3)  NOT NULL      -- Country key
);

-- T005 – Country Keys.
-- Stores country codes and names used by company codes, plants, and vendors.
CREATE TABLE t005 (
    land1 VARCHAR(3) PRIMARY KEY,   -- Country key
    landx VARCHAR(50) NOT NULL      -- Country name
);

-- T006 – Units of Measure.
-- Stores unit-of-measure codes and their descriptions used for materials and quantities.
CREATE TABLE t006 (
    meins VARCHAR(3) PRIMARY KEY,    -- Unit of measure
    mseh3 VARCHAR(15) NOT NULL,      -- UoM text (short description)
    mtext VARCHAR(50) NOT NULL       -- UoM text (long description)
);

-- T023 – Material Groups.
-- Stores material group codes and their descriptive texts used to
-- categorize materials in the MARA master data table.
CREATE TABLE t023 (
    matkl VARCHAR(9)  PRIMARY KEY,   -- Material group
    wgbez VARCHAR(40) NOT NULL       -- Material group description
);

-- T134 – Material Types.
-- Stores material type codes and their descriptions used to classify
-- materials in the MARA master data table.
CREATE TABLE t134 (
    mtart VARCHAR(4) PRIMARY KEY,   -- Material type
    mtbez VARCHAR(40) NOT NULL      -- Material type description
);

-- T156 – Movement Types.
-- Stores movement type definitions used to classify material and stock movements.
CREATE TABLE t156 (
    bwart VARCHAR(3) PRIMARY KEY,     -- Movement type
    btext VARCHAR(60) NOT NULL        -- Movement type description
);

-- CSKS – Cost Center Master Data.
-- Stores cost center identifiers, their company code assignment, and descriptive names.
CREATE TABLE csks (
    kostl VARCHAR(10) PRIMARY KEY,  -- Cost center
    bukrs VARCHAR(4)  NOT NULL,     -- Company code
    ktext VARCHAR(40) NOT NULL      -- Cost center name (short text)
);

-- MARA – General Material Master Data.
-- Stores cross-plant material attributes forming the core identification layer for all materials.
CREATE TABLE mara (
    matnr VARCHAR(40) PRIMARY KEY,  -- Material number
    mtart VARCHAR(4)  NOT NULL,     -- Material type
    matkl VARCHAR(9)  NOT NULL,     -- Material group
    meins VARCHAR(3)  NOT NULL      -- Base unit of measure
);

-- MARD – Storage Location Material Data.
-- Stores plant- and storage-location-level inventory attributes, including unrestricted-use stock.
CREATE TABLE mard (
    matnr VARCHAR(40)  NOT NULL,         -- Material number
    werks VARCHAR(4)   NOT NULL,         -- Plant
    lgort VARCHAR(4)   NOT NULL,         -- Storage location
    labst NUMERIC(13,3) NOT NULL         -- Valuated unrestricted-use stock
);

-- MBEW – Material Valuation Data.
-- Stores valuation metrics per material and valuation area, including standard price and price unit.
CREATE TABLE mbew (
    matnr VARCHAR(40)   NOT NULL,        -- Material number
    bwkey VARCHAR(4)    NOT NULL,        -- Valuation area (we map it to plant)
    stprs NUMERIC(11,2) NOT NULL,        -- Standard price
    peinh NUMERIC(5,0)  NOT NULL         -- Price unit
);

-- LFA1 – Vendor Master (General Data).
-- Stores global vendor attributes such as vendor ID, name, and country, independent of company code.
CREATE TABLE lfa1 (
    lifnr VARCHAR(10) PRIMARY KEY,  -- Vendor ID / account number
    name1 VARCHAR(35) NOT NULL,     -- Vendor name
    land1 VARCHAR(3)  NOT NULL      -- Country key
);

-- EKKO – Purchasing Document Header.
-- Stores header-level information for purchase orders, such as vendor, company code, date, and currency.
CREATE TABLE ekko (
    ebeln VARCHAR(10) PRIMARY KEY,  -- Purchasing document number
    bukrs VARCHAR(4)  NOT NULL,     -- Company code
    lifnr VARCHAR(10) NOT NULL,     -- Vendor
    bedat DATE        NOT NULL,     -- Purchasing document date
    waers VARCHAR(5)  NOT NULL      -- Currency key
);

-- EKPO – Purchasing Document Item.
-- Stores item-level details for purchase orders, including material, plant, quantity, and pricing.
CREATE TABLE ekpo (
    ebeln VARCHAR(10)  NOT NULL,        -- PO number
    ebelp INTEGER      NOT NULL,        -- PO item number
    matnr VARCHAR(40)  NOT NULL,        -- Material
    werks VARCHAR(4)   NOT NULL,        -- Plant
    menge NUMERIC(13,3) NOT NULL,       -- Order quantity
    meins VARCHAR(3)   NOT NULL,        -- Order unit
    netpr NUMERIC(11,2) NOT NULL,       -- Net price (per price unit)
    peinh NUMERIC(5,0)  NOT NULL,       -- Price unit
    netwr NUMERIC(15,2) NOT NULL        -- Net item value
);

-- EKBE – Purchasing Document History.
-- Stores history records for purchase order items, including GR/IR events, quantities, and amounts.
CREATE TABLE ekbe (
    ebeln VARCHAR(10)  NOT NULL,        -- PO number
    ebelp INTEGER      NOT NULL,        -- PO item
    vgabe CHAR(1)      NOT NULL,        -- Event type (1=GR,2=IR,...)
    gjahr INTEGER      NOT NULL,        -- Year of follow-on document
    belnr VARCHAR(10)  NOT NULL,        -- Follow-on document number
    buzei INTEGER      NOT NULL,        -- Item in follow-on document
    budat DATE         NOT NULL,        -- Posting date
    menge NUMERIC(13,3) NOT NULL,       -- Quantity
    dmbtr NUMERIC(15,2) NOT NULL        -- Amount in local currency
);

-- MKPF – Material Document Header.
-- Stores header-level information for material documents such as document number, year, and posting date.
CREATE TABLE mkpf (
    mblnr VARCHAR(10) NOT NULL,  -- Material document number
    mjahr INTEGER     NOT NULL,  -- Material document year
    budat DATE        NOT NULL   -- Posting date
);

-- MSEG – Material Document Item.
-- Stores item-level lines of material documents, including movement type, quantity, value, and stock location.
CREATE TABLE mseg (
    mblnr VARCHAR(10)  NOT NULL,        -- Material document number
    mjahr INTEGER      NOT NULL,        -- Material document year
    zeile INTEGER      NOT NULL,        -- Item in material document
    matnr VARCHAR(40)  NOT NULL,        -- Material
    werks VARCHAR(4)   NOT NULL,        -- Plant
    lgort VARCHAR(4)   NOT NULL,        -- Storage location
    kostl VARCHAR(10)  NOT NULL,        -- Cost center
    bwart VARCHAR(3)   NOT NULL,        -- Movement type
    menge NUMERIC(13,3) NOT NULL,       -- Quantity
    meins VARCHAR(3)   NOT NULL,        -- Unit of measure
    dmbtr NUMERIC(15,2) NOT NULL,       -- Amount in local currency
    waers VARCHAR(5)   NOT NULL         -- Currency
);

-- RBKP – Invoice Document Header.
-- Stores header-level information for vendor invoices, including document number, vendor, dates, and currency.
CREATE TABLE rbkp (
    belnr VARCHAR(10) NOT NULL,   -- Invoice document number
    gjahr INTEGER     NOT NULL,   -- Fiscal year
    bukrs VARCHAR(4)  NOT NULL,   -- Company code
    lifnr VARCHAR(10) NOT NULL,   -- Vendor
    bldat DATE        NOT NULL,   -- Invoice document date
    budat DATE        NOT NULL,   -- Posting date
    waers VARCHAR(5)  NOT NULL    -- Currency
);

-- RSEG – Invoice Document Item.
-- Stores item-level invoice data, linking PO items to invoiced quantities and amounts.
CREATE TABLE rseg (
    belnr VARCHAR(10)  NOT NULL,        -- Invoice document number
    gjahr INTEGER      NOT NULL,        -- Fiscal year
    buzei INTEGER      NOT NULL,        -- Invoice line item
    ebeln VARCHAR(10)  NOT NULL,        -- PO number
    ebelp INTEGER      NOT NULL,        -- PO item
    matnr VARCHAR(40)  NOT NULL,        -- Material
    menge NUMERIC(13,3) NOT NULL,       -- Invoiced quantity
    meins VARCHAR(3)    NOT NULL,       -- Unit of measure
    wrbtr NUMERIC(15,2) NOT NULL        -- Amount in document currency
);
