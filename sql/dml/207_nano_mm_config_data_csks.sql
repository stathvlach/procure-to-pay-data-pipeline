-- =====================================================================
-- Project : nano-mm
-- File    : 20_nano_mm_config_data_csks.sql
-- Purpose : Insert configuration data for table CSKS (Cost Centers).
--
-- Description:
--   This script loads a demo set of cost center master records, grouped
--   into CAPEX and OPEX categories. These cost centers represent internal
--   responsibility units for budgeting, cost allocation, and spend
--   analytics within the nano-mm schema.
--
-- Notes:
--   - All cost centers belong to company code 1000.
--   - Naming and descriptions follow SAP-style conventions.
--   - Designed to be safely re-runnable during container initialization.
--
-- Execution context:
--   Automatically executed by Postgres via /docker-entrypoint-initdb.d
--   during database setup.
--
-- Author  : Stathis Vlachos
-- =====================================================================

-- Capex
INSERT INTO csks (kostl, bukrs, ktext) VALUES ('C10001', '1000', 'New Equipment Investments');
INSERT INTO csks (kostl, bukrs, ktext) VALUES ('C10002', '1000', 'IT Infrastructure Capex');
INSERT INTO csks (kostl, bukrs, ktext) VALUES ('C10003', '1000', 'Plant Expansion Projects');
INSERT INTO csks (kostl, bukrs, ktext) VALUES ('C10004', '1000', 'Facilities Modernization');
INSERT INTO csks (kostl, bukrs, ktext) VALUES ('C10005', '1000', 'Machinery Replacement Capex');
-- Opex
INSERT INTO csks (kostl, bukrs, ktext) VALUES ('O20001', '1000', 'Maintenance Operations');
INSERT INTO csks (kostl, bukrs, ktext) VALUES ('O20002', '1000', 'Logistics Operations');
INSERT INTO csks (kostl, bukrs, ktext) VALUES ('O20003', '1000', 'Administrative Expenses');
INSERT INTO csks (kostl, bukrs, ktext) VALUES ('O20004', '1000', 'Quality Assurance Operations');
