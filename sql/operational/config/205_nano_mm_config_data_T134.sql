-- =====================================================================
-- Project : nano-mm
-- File    : 20_nano_mm_config_data_t134.sql
-- Purpose : Insert configuration data for table T134 (Material Types).
--
-- Description:
--   This script loads material type reference data used by the MARA
--   material master. Material types classify materials by functional
--   characteristics such as raw materials, finished goods, or services.
--
-- Notes:
--   - Keys and descriptions follow simplified SAP MM conventions.
--   - Must be executed after table creation and constraint scripts.
--   - Designed to be safely re-runnable during container initialization.
--
-- Execution context:
--   Automatically executed by Postgres via /docker-entrypoint-initdb.d.
--
-- Author  : Stathis Vlachos
-- =====================================================================

INSERT INTO operational.t134 (mtart, mtbez) VALUES ('ROH', 'Raw Materials');
INSERT INTO operational.t134 (mtart, mtbez) VALUES ('HALB', 'Semi-Finished Products');
INSERT INTO operational.t134 (mtart, mtbez) VALUES ('FERT', 'Finished Products');
INSERT INTO operational.t134 (mtart, mtbez) VALUES ('VERP', 'Packaging Materials');
INSERT INTO operational.t134 (mtart, mtbez) VALUES ('HIBE', 'Operating Supplies');
INSERT INTO operational.t134 (mtart, mtbez) VALUES ('NLAG', 'Non-Stock Materials');
INSERT INTO operational.t134 (mtart, mtbez) VALUES ('SERV', 'Services');
INSERT INTO operational.t134 (mtart, mtbez) VALUES ('ZMAT', 'Custom Demo Material Type');
