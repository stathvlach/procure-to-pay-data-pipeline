-- =====================================================================
-- Project : nano-mm-oltp
-- File    : 01_nano_mm_create_tables.sql
-- Purpose : Create all core OLTP tables in the nano_mm schema
--           (master data + transactional structures).
--
-- Description:
--   This script defines the full set of operational tables that form the
--   nano_mm OLTP data model inspired by SAP MM (Materials Management).
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

CREATE TABLE t001 (
    bukrs VARCHAR(4)  PRIMARY KEY,  -- Company code
    butxt VARCHAR(50) NOT NULL,     -- Company code name
    land1 VARCHAR(3)  NOT NULL,     -- Country key
    waers VARCHAR(5)  NOT NULL      -- Company code currency
);

CREATE TABLE t001w (
    werks VARCHAR(4)  PRIMARY KEY,  -- Plant
    name1 VARCHAR(30) NOT NULL,     -- Plant name
    land1 VARCHAR(3)  NOT NULL      -- Country key
);

CREATE TABLE mara (
    matnr VARCHAR(40) PRIMARY KEY,  -- Material number
    mtart VARCHAR(4)  NOT NULL,     -- Material type
    matkl VARCHAR(9)  NOT NULL,     -- Material group
    meins VARCHAR(3)  NOT NULL      -- Base unit of measure
);

CREATE TABLE mard (
    matnr VARCHAR(40)  NOT NULL,         -- Material number
    werks VARCHAR(4)   NOT NULL,         -- Plant
    lgort VARCHAR(4)   NOT NULL,         -- Storage location
    labst NUMERIC(13,3) NOT NULL,        -- Valuated unrestricted-use stock

    CONSTRAINT mard_pkey PRIMARY KEY (matnr, werks, lgort),

    CONSTRAINT mard_matnr_fk FOREIGN KEY (matnr)
        REFERENCES mara (matnr),

    CONSTRAINT mard_werks_fk FOREIGN KEY (werks)
        REFERENCES t001w (werks)
);

CREATE TABLE mbew (
    matnr VARCHAR(40)   NOT NULL,        -- Material number
    bwkey VARCHAR(4)    NOT NULL,        -- Valuation area (we map it to plant)
    stprs NUMERIC(11,2) NOT NULL,        -- Standard price
    peinh NUMERIC(5,0)  NOT NULL,        -- Price unit

    CONSTRAINT mbew_pkey PRIMARY KEY (matnr, bwkey),

    CONSTRAINT mbew_matnr_fk FOREIGN KEY (matnr)
        REFERENCES mara (matnr),

    -- In our simplified schema BWKEY == WERKS
    CONSTRAINT mbew_bwkey_fk FOREIGN KEY (bwkey)
        REFERENCES t001w (werks)
);


CREATE TABLE lfa1 (
    lifnr VARCHAR(10) PRIMARY KEY,  -- Vendor ID / account number
    name1 VARCHAR(35) NOT NULL,     -- Vendor name
    land1 VARCHAR(3)  NOT NULL      -- Country key
);


CREATE TABLE ekko (
    ebeln VARCHAR(10) PRIMARY KEY,  -- Purchasing document number
    bukrs VARCHAR(4)  NOT NULL,     -- Company code
    lifnr VARCHAR(10) NOT NULL,     -- Vendor
    bedat DATE        NOT NULL,     -- Purchasing document date
    waers VARCHAR(5)  NOT NULL,     -- Currency key

    CONSTRAINT ekko_bukrs_fk FOREIGN KEY (bukrs)
        REFERENCES t001 (bukrs),

    CONSTRAINT ekko_lifnr_fk FOREIGN KEY (lifnr)
        REFERENCES lfa1 (lifnr)
);

CREATE TABLE ekpo (
    ebeln VARCHAR(10)  NOT NULL,        -- PO number
    ebelp INTEGER      NOT NULL,        -- PO item number
    matnr VARCHAR(40)  NOT NULL,        -- Material
    werks VARCHAR(4)   NOT NULL,        -- Plant
    menge NUMERIC(13,3) NOT NULL,       -- Order quantity
    meins VARCHAR(3)   NOT NULL,        -- Order unit
    netpr NUMERIC(11,2) NOT NULL,       -- Net price (per price unit)
    peinh NUMERIC(5,0)  NOT NULL,       -- Price unit
    netwr NUMERIC(15,2) NOT NULL,       -- Net item value

    CONSTRAINT ekpo_pkey PRIMARY KEY (ebeln, ebelp),

    CONSTRAINT ekpo_ekko_fk FOREIGN KEY (ebeln)
        REFERENCES ekko (ebeln),

    CONSTRAINT ekpo_matnr_fk FOREIGN KEY (matnr)
        REFERENCES mara (matnr),

    CONSTRAINT ekpo_werks_fk FOREIGN KEY (werks)
        REFERENCES t001w (werks)
);


CREATE TABLE ekbe (
    ebeln VARCHAR(10)  NOT NULL,        -- PO number
    ebelp INTEGER      NOT NULL,        -- PO item
    vgabe CHAR(1)      NOT NULL,        -- Event type (1=GR,2=IR,...)
    gjahr INTEGER      NOT NULL,        -- Year of follow-on document
    belnr VARCHAR(10)  NOT NULL,        -- Follow-on document number
    buzei INTEGER      NOT NULL,        -- Item in follow-on document
    budat DATE         NOT NULL,        -- Posting date
    menge NUMERIC(13,3) NOT NULL,       -- Quantity
    dmbtr NUMERIC(15,2) NOT NULL,       -- Amount in local currency

    CONSTRAINT ekbe_pkey PRIMARY KEY (ebeln, ebelp, vgabe, gjahr, belnr, buzei),

    CONSTRAINT ekbe_ekpo_fk FOREIGN KEY (ebeln, ebelp)
        REFERENCES ekpo (ebeln, ebelp)
);


CREATE TABLE mkpf (
    mblnr VARCHAR(10) NOT NULL,  -- Material document number
    mjahr INTEGER     NOT NULL,  -- Material document year
    budat DATE        NOT NULL,  -- Posting date

    CONSTRAINT mkpf_pkey PRIMARY KEY (mblnr, mjahr)
);


CREATE TABLE mseg (
    mblnr VARCHAR(10)  NOT NULL,        -- Material document number
    mjahr INTEGER      NOT NULL,        -- Material document year
    zeile INTEGER      NOT NULL,        -- Item in material document

    matnr VARCHAR(40)  NOT NULL,        -- Material
    werks VARCHAR(4)   NOT NULL,        -- Plant
    lgort VARCHAR(4)   NOT NULL,        -- Storage location
    bwart VARCHAR(3)   NOT NULL,        -- Movement type
    menge NUMERIC(13,3) NOT NULL,       -- Quantity
    meins VARCHAR(3)   NOT NULL,        -- Unit of measure
    dmbtr NUMERIC(15,2) NOT NULL,       -- Amount in local currency
    waers VARCHAR(5)   NOT NULL,        -- Currency

    CONSTRAINT mseg_pkey PRIMARY KEY (mblnr, mjahr, zeile),

    CONSTRAINT mseg_mkpf_fk FOREIGN KEY (mblnr, mjahr)
        REFERENCES mkpf (mblnr, mjahr),

    CONSTRAINT mseg_matnr_fk FOREIGN KEY (matnr)
        REFERENCES mara (matnr),

    CONSTRAINT mseg_werks_fk FOREIGN KEY (werks)
        REFERENCES t001w (werks)
);


CREATE TABLE rbkp (
    belnr VARCHAR(10) NOT NULL,   -- Invoice document number
    gjahr INTEGER     NOT NULL,   -- Fiscal year
    bukrs VARCHAR(4)  NOT NULL,   -- Company code
    lifnr VARCHAR(10) NOT NULL,   -- Vendor
    bldat DATE        NOT NULL,   -- Invoice document date
    budat DATE        NOT NULL,   -- Posting date
    waers VARCHAR(5)  NOT NULL,   -- Currency

    CONSTRAINT rbkp_pkey PRIMARY KEY (belnr, gjahr),

    CONSTRAINT rbkp_bukrs_fk FOREIGN KEY (bukrs)
        REFERENCES t001 (bukrs),

    CONSTRAINT rbkp_lifnr_fk FOREIGN KEY (lifnr)
        REFERENCES lfa1 (lifnr)
);


CREATE TABLE rseg (
    belnr VARCHAR(10)  NOT NULL,        -- Invoice document number
    gjahr INTEGER      NOT NULL,        -- Fiscal year
    buzei INTEGER      NOT NULL,        -- Invoice line item

    ebeln VARCHAR(10)  NOT NULL,        -- PO number
    ebelp INTEGER      NOT NULL,        -- PO item
    matnr VARCHAR(40)  NOT NULL,        -- Material

    menge NUMERIC(13,3) NOT NULL,       -- Invoiced quantity
    meins VARCHAR(3)    NOT NULL,       -- Unit of measure
    wrbtr NUMERIC(15,2) NOT NULL,       -- Amount in document currency

    CONSTRAINT rseg_pkey PRIMARY KEY (belnr, gjahr, buzei),

    CONSTRAINT rseg_rbkp_fk FOREIGN KEY (belnr, gjahr)
        REFERENCES rbkp (belnr, gjahr),

    CONSTRAINT rseg_ekpo_fk FOREIGN KEY (ebeln, ebelp)
        REFERENCES ekpo (ebeln, ebelp),

    CONSTRAINT rseg_matnr_fk FOREIGN KEY (matnr)
        REFERENCES mara (matnr)
);




