-- =====================================================================
-- Project : nano-mm
-- File    : 20_nano_mm_config_data_t006.sql
-- Purpose : Insert configuration data for table T006 (Units of Measure).
--
-- Description:
--   This script loads unit-of-measure master data used across materials,
--   purchasing documents, inventory movements, and invoice verification.
--   Units follow standard SAP-style naming and include both simple and
--   logistics-oriented measurements.
--
-- Notes:
--   - UoM keys follow common SAP MM conventions (EA, KG, L, M, etc.).
--   - Must be executed after table creation and constraint scripts.
--   - Designed to be safely re-runnable during container initialization.
--
-- Execution context:
--   Automatically executed by Postgres via /docker-entrypoint-initdb.d
--   during database setup.
--
-- Author  : Stathis Vlachos
-- =====================================================================

INSERT INTO t006 (meins, mseh3, mtext) VALUES ('EA',  'Each', 'Each (individual unit)');
INSERT INTO t006 (meins, mseh3, mtext) VALUES ('PCE', 'Piece', 'Piece (individual item)');
INSERT INTO t006 (meins, mseh3, mtext) VALUES ('KG',  'Kilogram', 'Kilogram (kg)');
INSERT INTO t006 (meins, mseh3, mtext) VALUES ('G',   'Gram', 'Gram (g)');
INSERT INTO t006 (meins, mseh3, mtext) VALUES ('L',   'Liter', 'Liter (l)');
INSERT INTO t006 (meins, mseh3, mtext) VALUES ('ML',  'Milliliter', 'Milliliter (ml)');
INSERT INTO t006 (meins, mseh3, mtext) VALUES ('M',   'Meter', 'Meter (m)');
INSERT INTO t006 (meins, mseh3, mtext) VALUES ('CM',  'Centimeter', 'Centimeter (cm)');
INSERT INTO t006 (meins, mseh3, mtext) VALUES ('MM',  'Millimeter', 'Millimeter (mm)');
INSERT INTO t006 (meins, mseh3, mtext) VALUES ('BOX', 'Box', 'Box (packaged set of units)');
INSERT INTO t006 (meins, mseh3, mtext) VALUES ('PK',  'Pack', 'Pack (multiple units packaged)');
INSERT INTO t006 (meins, mseh3, mtext) VALUES ('SET', 'Set', 'Set (collection of items)');
INSERT INTO t006 (meins, mseh3, mtext) VALUES ('BAG', 'Bag', 'Bag (loose materials)');
INSERT INTO t006 (meins, mseh3, mtext) VALUES ('PAL', 'Pallet', 'Pallet (logistics handling unit)');
INSERT INTO t006 (meins, mseh3, mtext) VALUES ('ROL', 'Roll', 'Roll (material wound onto a core)');
