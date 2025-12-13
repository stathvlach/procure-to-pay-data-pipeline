-- =====================================================================
-- Project : nano-mm
-- File    : 20_nano_mm_config_data_t023.sql
-- Purpose : Insert configuration data for table T023 (Material Groups).
--
-- Description:
--   This script loads material group reference data used by the MARA
--   material master. Material groups cluster materials with similar
--   procurement or usage characteristics, enabling spend analytics and
--   category-based reporting.
--
-- Notes:
--   - Values follow simplified SAP MM conventions.
--   - Must be executed after table creation and constraint scripts.
--   - Designed to be safely re-runnable during container initialization.
--
-- Execution context:
--   Automatically executed by Postgres via /docker-entrypoint-initdb.d
--   during database setup.
--
-- Author  : Stathis Vlachos
-- =====================================================================

INSERT INTO t023 (matkl, wgbez) VALUES ('100000001', 'Electrical Components');
INSERT INTO t023 (matkl, wgbez) VALUES ('100000002', 'Mechanical Parts');
INSERT INTO t023 (matkl, wgbez) VALUES ('100000003', 'Packaging Materials');
INSERT INTO t023 (matkl, wgbez) VALUES ('100000004', 'Office Supplies');
INSERT INTO t023 (matkl, wgbez) VALUES ('100000005', 'IT Equipment');
INSERT INTO t023 (matkl, wgbez) VALUES ('100000006', 'Safety and PPE');
INSERT INTO t023 (matkl, wgbez) VALUES ('100000007', 'Tools and Workshop Equipment');
INSERT INTO t023 (matkl, wgbez) VALUES ('100000008', 'Chemical Consumables');
INSERT INTO t023 (matkl, wgbez) VALUES ('100000009', 'Maintenance Spare Parts');
INSERT INTO t023 (matkl, wgbez) VALUES ('100000010', 'Cleaning Supplies');
INSERT INTO t023 (matkl, wgbez) VALUES ('100000011', 'Logistics Handling Units');
INSERT INTO t023 (matkl, wgbez) VALUES ('100000012', 'Raw Material Categories');
INSERT INTO t023 (matkl, wgbez) VALUES ('100000013', 'Finished Goods Categories');
INSERT INTO t023 (matkl, wgbez) VALUES ('100000014', 'Service Procurement');
INSERT INTO t023 (matkl, wgbez) VALUES ('100000015', 'Custom Demo Material Group');
