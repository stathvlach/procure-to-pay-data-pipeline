-- =====================================================================
-- Project : nano-mm
-- File    : 20_nano_mm_config_data_t001w.sql
-- Purpose : Insert configuration data for table T001W (Plants).
--
-- Description:
--   This script loads a set of demo plant master records used across the
--   nano-mm schema. Plants represent physical or logical locations where
--   materials are received, stored, consumed, or shipped.
--
--   The entries below follow a clean, SAP-style naming convention with
--   neutral identifiers suitable for demonstration and analytics
--   scenarios (e.g., warehouses, distribution centers, production units).
--
-- Notes:
--   - Must be executed after table creation and constraint scripts.
--   - Designed to be safely re-runnable during container initialization.
--
-- Execution context:
--   Automatically executed by Postgres via /docker-entrypoint-initdb.d
--   during database setup.
--
-- Author  : Stathis Vlachos
-- =====================================================================

INSERT INTO operational.t001w (werks, name1, land1) VALUES ('1000', 'Main Plant', 'GR');
INSERT INTO operational.t001w (werks, name1, land1) VALUES ('1100', 'Warehouse North', 'GR');
INSERT INTO operational.t001w (werks, name1, land1) VALUES ('1200', 'Warehouse South', 'GR');
INSERT INTO operational.t001w (werks, name1, land1) VALUES ('1300', 'Regional DC East', 'GR');
INSERT INTO operational.t001w (werks, name1, land1) VALUES ('1400', 'Regional DC West', 'GR');
INSERT INTO operational.t001w (werks, name1, land1) VALUES ('1500', 'Production Unit A', 'GR');
INSERT INTO operational.t001w (werks, name1, land1) VALUES ('1600', 'Production Unit B', 'GR');
INSERT INTO operational.t001w (werks, name1, land1) VALUES ('1700', 'Assembly Center', 'GR');
INSERT INTO operational.t001w (werks, name1, land1) VALUES ('1800', 'Repair & Returns Center', 'GR');
INSERT INTO operational.t001w (werks, name1, land1) VALUES ('1900', 'Export Logistics Hub', 'GR');
INSERT INTO operational.t001w (werks, name1, land1) VALUES ('2000', 'EU DC North (Demo)', 'DE');
INSERT INTO operational.t001w (werks, name1, land1) VALUES ('2100', 'EU DC Central (Demo)', 'DE');
INSERT INTO operational.t001w (werks, name1, land1) VALUES ('2200', 'EU DC South (Demo)', 'IT');
INSERT INTO operational.t001w (werks, name1, land1) VALUES ('2300', 'EU Production Site A', 'IT');
INSERT INTO operational.t001w (werks, name1, land1) VALUES ('2400', 'EU Production Site B', 'FR');
