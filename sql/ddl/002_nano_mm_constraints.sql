-- =====================================================================
-- Project : nano-mm
-- File    : 02_nano_mm_create_constraints.sql
-- Purpose : Define all primary keys, foreign keys, and relational
--           integrity rules for the nano_mm OLTP schema.
--
-- Description:
--   This script applies structural constraints to the tables created in
--   01_nano_mm_create_tables.sql. It establishes:
--     - Primary keys for all master data and transaction tables
--     - Foreign key relationships across procurement, inventory, and
--       invoice verification processes
--     - Referential integrity between master data (materials, vendors,
--       plants, company codes) and their dependent transactional records
--
--   These constraints ensure data quality, enforce relational rules, and
--   align the nano_mm schema with SAP MM–inspired organizational and
--   process structures.
--
-- Notes:
--   - This script must be executed after all base tables are created.
--   - Constraint names follow a consistent, readable pattern:
--         <table>_<column(s)>_<type>
--     e.g. mseg_matnr_fk, ekpo_pkey.
--   - Additional indexes may be defined in subsequent scripts depending
--     on ETL or analytical performance requirements.
--
-- Execution context:
--   Automatically executed by Postgres via /docker-entrypoint-initdb.d
--   during container initialization.
--
-- Author  : Stathis Vlachos
-- =====================================================================

ALTER TABLE mara
    ADD CONSTRAINT mara_mtart_fk FOREIGN KEY (mtart) REFERENCES t134 (mtart),
    ADD CONSTRAINT mara_matkl_fk FOREIGN KEY (matkl) REFERENCES t023 (matkl);
;

ALTER TABLE mard
    ADD CONSTRAINT mard_pkey PRIMARY KEY (matnr, werks, lgort),
    ADD CONSTRAINT mard_matnr_fk FOREIGN KEY (matnr) REFERENCES mara (matnr),
    ADD CONSTRAINT mard_werks_fk FOREIGN KEY (werks) REFERENCES t001w (werks)
;

ALTER TABLE mbew
    ADD CONSTRAINT mbew_pkey PRIMARY KEY (matnr, bwkey),
    ADD CONSTRAINT mbew_matnr_fk FOREIGN KEY (matnr) REFERENCES mara (matnr),
    ADD CONSTRAINT mbew_bwkey_fk FOREIGN KEY (bwkey) REFERENCES t001w (werks) --  simplified schema BWKEY == WERKS
;

ALTER TABLE ekko
    ADD CONSTRAINT ekko_bukrs_fk FOREIGN KEY (bukrs) REFERENCES t001 (bukrs),
    ADD CONSTRAINT ekko_lifnr_fk FOREIGN KEY (lifnr) REFERENCES lfa1 (lifnr)
;

ALTER TABLE ekpo
    ADD CONSTRAINT ekpo_pkey PRIMARY KEY (ebeln, ebelp),
    ADD CONSTRAINT ekpo_ekko_fk FOREIGN KEY (ebeln) REFERENCES ekko (ebeln),
    ADD CONSTRAINT ekpo_matnr_fk FOREIGN KEY (matnr) REFERENCES mara (matnr),
    ADD CONSTRAINT ekpo_werks_fk FOREIGN KEY (werks) REFERENCES t001w (werks)
;

ALTER TABLE ekbe
    ADD CONSTRAINT ekbe_pkey PRIMARY KEY (ebeln, ebelp, vgabe, gjahr, belnr, buzei),
    ADD CONSTRAINT ekbe_ekpo_fk FOREIGN KEY (ebeln, ebelp) REFERENCES ekpo (ebeln, ebelp)
;

ALTER TABLE mkpf
    ADD CONSTRAINT mkpf_pkey PRIMARY KEY (mblnr, mjahr)
;

ALTER TABLE mseg
    ADD CONSTRAINT mseg_pkey PRIMARY KEY (mblnr, mjahr, zeile),
    ADD CONSTRAINT mseg_mkpf_fk FOREIGN KEY (mblnr, mjahr) REFERENCES mkpf (mblnr, mjahr),
    ADD CONSTRAINT mseg_matnr_fk FOREIGN KEY (matnr) REFERENCES mara (matnr),
    ADD CONSTRAINT mseg_werks_fk FOREIGN KEY (werks) REFERENCES t001w (werks),
    ADD CONSTRAINT mseg_kostl_fk FOREIGN KEY (kostl) REFERENCES csks (kostl)
;

ALTER TABLE rbkp
    ADD CONSTRAINT rbkp_pkey PRIMARY KEY (belnr, gjahr),
    ADD CONSTRAINT rbkp_bukrs_fk FOREIGN KEY (bukrs) REFERENCES t001 (bukrs),
    ADD CONSTRAINT rbkp_lifnr_fk FOREIGN KEY (lifnr) REFERENCES lfa1 (lifnr)
;

ALTER TABLE rseg
    ADD CONSTRAINT rseg_pkey PRIMARY KEY (belnr, gjahr, buzei),
    ADD CONSTRAINT rseg_rbkp_fk FOREIGN KEY (belnr, gjahr) REFERENCES rbkp (belnr, gjahr),
    ADD CONSTRAINT rseg_ekpo_fk FOREIGN KEY (ebeln, ebelp) REFERENCES ekpo (ebeln, ebelp),
    ADD CONSTRAINT rseg_matnr_fk FOREIGN KEY (matnr) REFERENCES mara (matnr)
;
