-- =====================================================================
-- Project : nano-mm
-- File    : 20_nano_mm_config_data_t005.sql
-- Purpose : Insert configuration data for table T005 (Country Keys).
--
-- Description:
--   This script loads ISO-based country keys and names used throughout
--   the nano-mm schema. These values serve as reference data for company
--   codes, plants, vendors, and all country-dependent analytics.
--
-- Notes:
--   - Uses ISO 3166-1 alpha-2 codes for simplified interoperability.
--   - Must be executed after table creation and constraint scripts.
--   - Designed to be safely re-runnable during container initialization.
--
-- Execution context:
--   Automatically executed by Postgres via /docker-entrypoint-initdb.d
--   during database setup.
--
-- Author  : Stathis Vlachos
-- =====================================================================

INSERT INTO t005 (land1, landx) VALUES ('AT', 'Austria');
INSERT INTO t005 (land1, landx) VALUES ('BE', 'Belgium');
INSERT INTO t005 (land1, landx) VALUES ('BG', 'Bulgaria');
INSERT INTO t005 (land1, landx) VALUES ('CH', 'Switzerland');
INSERT INTO t005 (land1, landx) VALUES ('CY', 'Cyprus');
INSERT INTO t005 (land1, landx) VALUES ('CZ', 'Czech Republic');
INSERT INTO t005 (land1, landx) VALUES ('DE', 'Germany');
INSERT INTO t005 (land1, landx) VALUES ('DK', 'Denmark');
INSERT INTO t005 (land1, landx) VALUES ('EE', 'Estonia');
INSERT INTO t005 (land1, landx) VALUES ('ES', 'Spain');
INSERT INTO t005 (land1, landx) VALUES ('FI', 'Finland');
INSERT INTO t005 (land1, landx) VALUES ('FR', 'France');
INSERT INTO t005 (land1, landx) VALUES ('GR', 'Greece');
INSERT INTO t005 (land1, landx) VALUES ('HR', 'Croatia');
INSERT INTO t005 (land1, landx) VALUES ('HU', 'Hungary');
INSERT INTO t005 (land1, landx) VALUES ('IE', 'Ireland');
INSERT INTO t005 (land1, landx) VALUES ('IT', 'Italy');
INSERT INTO t005 (land1, landx) VALUES ('LT', 'Lithuania');
INSERT INTO t005 (land1, landx) VALUES ('LU', 'Luxembourg');
INSERT INTO t005 (land1, landx) VALUES ('LV', 'Latvia');
INSERT INTO t005 (land1, landx) VALUES ('MT', 'Malta');
INSERT INTO t005 (land1, landx) VALUES ('NL', 'Netherlands');
INSERT INTO t005 (land1, landx) VALUES ('NO', 'Norway');
INSERT INTO t005 (land1, landx) VALUES ('PL', 'Poland');
INSERT INTO t005 (land1, landx) VALUES ('PT', 'Portugal');
INSERT INTO t005 (land1, landx) VALUES ('RO', 'Romania');
INSERT INTO t005 (land1, landx) VALUES ('RU', 'Russia');
INSERT INTO t005 (land1, landx) VALUES ('SE', 'Sweden');
INSERT INTO t005 (land1, landx) VALUES ('SI', 'Slovenia');
INSERT INTO t005 (land1, landx) VALUES ('SK', 'Slovakia');
INSERT INTO t005 (land1, landx) VALUES ('TR', 'Turkey');
INSERT INTO t005 (land1, landx) VALUES ('UA', 'Ukraine');
