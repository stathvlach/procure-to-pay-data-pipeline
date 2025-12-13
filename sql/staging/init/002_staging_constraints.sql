-- =====================================================================
-- Project : Procure-to-Pay Data Platform
-- Layer   : staging
-- Folder  : init
-- File    : 002_staging_constraints.sql
--
-- Purpose :
--   Apply primary keys and NOT NULL constraints to staging silver tables
--   to enforce cleaned, standardized, and structurally valid datasets.
--
-- Description:
--   This script defines structural constraints for the staging silver layer.
--   Silver tables represent the refined output of the medallion process and
--   must be suitable for deterministic downstream loading into the operational
--   schema.
--
--   Constraints applied:
--     - NOT NULL on key fields and required attributes
--     - PRIMARY KEY constraints using SAP-like business keys
--
--   No foreign key constraints are applied in staging. Referential integrity
--   is enforced later in the operational schema.
--
-- Inputs :
--   Tables created by 001_staging_create_tables.sql
--
-- Outputs:
--   PK and NOT NULL constraints applied to:
--     - staging.silver_ekko
--     - staging.silver_ekpo
--     - staging.silver_mkpf
--     - staging.silver_mseg
--     - staging.silver_rbkp
--     - staging.silver_rseg
--
-- Execution Context:
--   Executed during database initialization after staging tables are created.
--
-- Author : Stathis Vlachos
-- =====================================================================

-- EKKO (PO Header)
ALTER TABLE staging.silver_ekko
    ALTER COLUMN ebeln SET NOT NULL,
    ALTER COLUMN bukrs SET NOT NULL,
    ALTER COLUMN lifnr SET NOT NULL,
    ALTER COLUMN bedat SET NOT NULL,
    ALTER COLUMN waers SET NOT NULL;

ALTER TABLE staging.silver_ekko
    ADD CONSTRAINT pk_silver_ekko PRIMARY KEY (ebeln);

-- EKPO (PO Item)
ALTER TABLE staging.silver_ekpo
    ALTER COLUMN ebeln SET NOT NULL,
    ALTER COLUMN ebelp SET NOT NULL,
    ALTER COLUMN matnr SET NOT NULL,
    ALTER COLUMN werks SET NOT NULL,
    ALTER COLUMN menge SET NOT NULL,
    ALTER COLUMN meins SET NOT NULL,
    ALTER COLUMN netpr SET NOT NULL,
    ALTER COLUMN peinh SET NOT NULL,
    ALTER COLUMN netwr SET NOT NULL;

ALTER TABLE staging.silver_ekpo
    ADD CONSTRAINT pk_silver_ekpo PRIMARY KEY (ebeln, ebelp);

-- MKPF (Material Document Header)
ALTER TABLE staging.silver_mkpf
    ALTER COLUMN mblnr SET NOT NULL,
    ALTER COLUMN mjahr SET NOT NULL,
    ALTER COLUMN budat SET NOT NULL;

ALTER TABLE staging.silver_mkpf
    ADD CONSTRAINT pk_silver_mkpf PRIMARY KEY (mblnr, mjahr);

-- MSEG (Material Document Item)
ALTER TABLE staging.silver_mseg
    ALTER COLUMN mblnr SET NOT NULL,
    ALTER COLUMN mjahr SET NOT NULL,
    ALTER COLUMN zeile SET NOT NULL,
    ALTER COLUMN matnr SET NOT NULL,
    ALTER COLUMN werks SET NOT NULL,
    ALTER COLUMN lgort SET NOT NULL,
    ALTER COLUMN kostl SET NOT NULL,
    ALTER COLUMN bwart SET NOT NULL,
    ALTER COLUMN menge SET NOT NULL,
    ALTER COLUMN meins SET NOT NULL,
    ALTER COLUMN dmbtr SET NOT NULL,
    ALTER COLUMN waers SET NOT NULL;

ALTER TABLE staging.silver_mseg
    ADD CONSTRAINT pk_silver_mseg PRIMARY KEY (mblnr, mjahr, zeile);

-- RBKP (Invoice Header)
ALTER TABLE staging.silver_rbkp
    ALTER COLUMN belnr SET NOT NULL,
    ALTER COLUMN gjahr SET NOT NULL,
    ALTER COLUMN bukrs SET NOT NULL,
    ALTER COLUMN lifnr SET NOT NULL,
    ALTER COLUMN bldat SET NOT NULL,
    ALTER COLUMN budat SET NOT NULL,
    ALTER COLUMN waers SET NOT NULL;

ALTER TABLE staging.silver_rbkp
    ADD CONSTRAINT pk_silver_rbkp PRIMARY KEY (belnr, gjahr);

-- RSEG (Invoice Item)
ALTER TABLE staging.silver_rseg
    ALTER COLUMN belnr SET NOT NULL,
    ALTER COLUMN gjahr SET NOT NULL,
    ALTER COLUMN buzei SET NOT NULL,
    ALTER COLUMN ebeln SET NOT NULL,
    ALTER COLUMN ebelp SET NOT NULL,
    ALTER COLUMN matnr SET NOT NULL,
    ALTER COLUMN menge SET NOT NULL,
    ALTER COLUMN meins SET NOT NULL,
    ALTER COLUMN wrbtr SET NOT NULL;

ALTER TABLE staging.silver_rseg
    ADD CONSTRAINT pk_silver_rseg PRIMARY KEY (belnr, gjahr, buzei);
