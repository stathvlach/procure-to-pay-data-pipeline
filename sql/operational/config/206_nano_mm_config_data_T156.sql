-- =====================================================================
-- Project : nano-mm
-- File    : 20_nano_mm_config_data_t156.sql
-- Purpose : Insert configuration data for table T156 (Movement Types).
--
-- Description:
--   This script loads movement type definitions used by material
--   documents (MSEG) to classify stock movements such as goods receipts,
--   goods issues, transfer postings, and reversals.
--
-- Notes:
--   - Movement types follow simplified SAP MM conventions and support
--     the core P2P and inventory processes in the nano-mm dataset.
--   - Must be executed after table creation and constraint scripts.
--   - Designed to be safely re-runnable during container initialization.
--
-- Execution context:
--   Automatically executed by Postgres via /docker-entrypoint-initdb.d
--   during database setup.
--
-- Author  : Stathis Vlachos
-- =====================================================================

INSERT INTO operational.t156 (bwart, btext) VALUES ('101', 'Goods receipt for purchase order');
INSERT INTO operational.t156 (bwart, btext) VALUES ('102', 'Reversal of goods receipt for purchase order');
INSERT INTO operational.t156 (bwart, btext) VALUES ('122', 'Return delivery to vendor');
INSERT INTO operational.t156 (bwart, btext) VALUES ('201', 'Goods issue to cost center');
INSERT INTO operational.t156 (bwart, btext) VALUES ('261', 'Goods issue to production order');
INSERT INTO operational.t156 (bwart, btext) VALUES ('262', 'Reversal of goods issue to production order');
INSERT INTO operational.t156 (bwart, btext) VALUES ('311', 'Transfer posting: storage location to storage location');
INSERT INTO operational.t156 (bwart, btext) VALUES ('312', 'Reversal: storage location transfer');
INSERT INTO operational.t156 (bwart, btext) VALUES ('501', 'Goods receipt without purchase order');
INSERT INTO operational.t156 (bwart, btext) VALUES ('502', 'Reversal of goods receipt without purchase order');
INSERT INTO operational.t156 (bwart, btext) VALUES ('551', 'Scrapping of stock');
INSERT INTO operational.t156 (bwart, btext) VALUES ('552', 'Reversal of scrapping');
