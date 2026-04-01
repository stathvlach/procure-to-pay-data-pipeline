-- =====================================================================
-- Project : Procure-to-Pay Data Platform
-- Layer   : bootstrap
-- Folder  : config
-- File    : 201_bootstrap_table_corruption_config.sql
--
-- Purpose:
--   Configure which corruption rules apply to each transactional table and
--   define the corruption intensity and activation status per rule.
--
-- Description:
--   This script seeds table-level corruption configurations that specify
--   how corruption rules from the bootstrap rule catalog are applied to
--   specific transactional entities:
--     - EKKO / EKPO (Purchase Orders)
--     - MKPF / MSEG (Goods Movements)
--     - RBKP / RSEG (Invoices)
--
--   Each configuration entry maps:
--     - A target table (entity)
--     - A rule_code (from bootstrap.corruption_rule)
--     - An intensity value (e.g., percentage of affected rows/fields)
--     - An enabled flag (to activate/deactivate the rule)
--
--   Rule parameterization (e.g., targeted columns, ranges, offsets) is
--   defined separately in the rule-parameter script.
--
-- Inputs:
--   - Rule catalog seeded by 200_bootstrap_corruption_rules.sql
--   - Configuration tables created by 001_bootstrap_create_tables.sql
--
-- Outputs:
--   Seed data inserted into:
--     - bootstrap.table_corruption_config
--
-- Execution Context:
--   Executed during environment setup / re-seeding of the bootstrap layer.
--   Typically run after the corruption rule catalog has been populated.
--
-- Notes :
--   - This script should be idempotent to support repeated development runs
--     (e.g., INSERT...ON CONFLICT DO NOTHING, or TRUNCATE+INSERT in dev).
--   - Intensity semantics should be consistent across rules (e.g., 0.05 = 5%).
--
-- Author : Stathis Vlachos
-- =====================================================================
--
INSERT INTO bootstrap.table_corruption_config
(target_table, target_column, rule_code, assignment_probability, enabled)
VALUES

-- =========================================================
-- EKKO_CLEAN
-- =========================================================
('ekko_clean', 'ebeln', 'DUPLICATE_KEY',        0.0040, TRUE),
('ekko_clean', 'ebeln', 'INVALID_FORMAT',       0.0060, TRUE),
('ekko_clean', 'ebeln', 'TRUNCATED_VALUE',      0.0040, TRUE),

('ekko_clean', 'bukrs', 'NULLIFY_FIELD',        0.0060, TRUE),
('ekko_clean', 'bukrs', 'INVALID_FORMAT',       0.0060, TRUE),
('ekko_clean', 'bukrs', 'WRONG_FOREIGN_KEY',    0.0100, TRUE),

('ekko_clean', 'lifnr', 'NULLIFY_FIELD',        0.0080, TRUE),
('ekko_clean', 'lifnr', 'INVALID_FORMAT',       0.0070, TRUE),
('ekko_clean', 'lifnr', 'ORPHAN_REFERENCE',     0.0120, TRUE),
('ekko_clean', 'lifnr', 'WRONG_FOREIGN_KEY',    0.0100, TRUE),

('ekko_clean', 'bedat', 'NULLIFY_FIELD',        0.0060, TRUE),
('ekko_clean', 'bedat', 'INVALID_DATE',         0.0080, TRUE),
('ekko_clean', 'bedat', 'FUTURE_DATE',          0.0060, TRUE),
('ekko_clean', 'bedat', 'PAST_DATE_DRIFT',      0.0060, TRUE),

('ekko_clean', 'waers', 'NULLIFY_FIELD',        0.0050, TRUE),
('ekko_clean', 'waers', 'INVALID_FORMAT',       0.0070, TRUE),
('ekko_clean', 'waers', 'CURRENCY_MISMATCH',    0.0100, TRUE),

('ekko_clean', NULL,    'DUPLICATE_RECORD',     0.0030, TRUE),
('ekko_clean', NULL,    'MISSING_RECORD',       0.0020, TRUE),

-- =========================================================
-- EKPO_CLEAN
-- =========================================================
('ekpo_clean', 'ebeln', 'NULLIFY_FIELD',        0.0040, TRUE),
('ekpo_clean', 'ebeln', 'INVALID_FORMAT',       0.0060, TRUE),
('ekpo_clean', 'ebeln', 'ORPHAN_REFERENCE',     0.0120, TRUE),

('ekpo_clean', 'ebelp', 'NULLIFY_FIELD',        0.0030, TRUE),
('ekpo_clean', 'ebelp', 'NON_UNIQUE_COMPOSITE', 0.0060, TRUE),
('ekpo_clean', 'ebelp', 'OUT_OF_RANGE_HIGH',    0.0040, TRUE),
('ekpo_clean', 'ebelp', 'ZERO_VALUE_INVALID',   0.0040, TRUE),

('ekpo_clean', 'matnr', 'NULLIFY_FIELD',        0.0060, TRUE),
('ekpo_clean', 'matnr', 'INVALID_FORMAT',       0.0070, TRUE),
('ekpo_clean', 'matnr', 'TRUNCATED_VALUE',      0.0050, TRUE),
('ekpo_clean', 'matnr', 'ORPHAN_REFERENCE',     0.0150, TRUE),
('ekpo_clean', 'matnr', 'SEMANTIC_DRIFT',       0.0100, TRUE),

('ekpo_clean', 'werks', 'NULLIFY_FIELD',        0.0050, TRUE),
('ekpo_clean', 'werks', 'INVALID_FORMAT',       0.0060, TRUE),
('ekpo_clean', 'werks', 'ORPHAN_REFERENCE',     0.0120, TRUE),
('ekpo_clean', 'werks', 'WRONG_FOREIGN_KEY',    0.0150, TRUE),

('ekpo_clean', 'menge', 'NULLIFY_FIELD',        0.0040, TRUE),
('ekpo_clean', 'menge', 'NEGATIVE_VALUE',       0.0100, TRUE),
('ekpo_clean', 'menge', 'ZERO_VALUE_INVALID',   0.0100, TRUE),
('ekpo_clean', 'menge', 'OUT_OF_RANGE_HIGH',    0.0080, TRUE),
('ekpo_clean', 'menge', 'EXTREME_OUTLIER',      0.0060, TRUE),
('ekpo_clean', 'menge', 'ROUNDING_ERROR',       0.0100, TRUE),
('ekpo_clean', 'menge', 'SCALE_DISTORTION',     0.0060, TRUE),

('ekpo_clean', 'meins', 'NULLIFY_FIELD',        0.0040, TRUE),
('ekpo_clean', 'meins', 'INVALID_FORMAT',       0.0060, TRUE),
('ekpo_clean', 'meins', 'UNIT_MISMATCH',        0.0150, TRUE),
('ekpo_clean', 'meins', 'SEMANTIC_DRIFT',       0.0080, TRUE),

('ekpo_clean', 'netpr', 'NULLIFY_FIELD',        0.0040, TRUE),
('ekpo_clean', 'netpr', 'NEGATIVE_VALUE',       0.0100, TRUE),
('ekpo_clean', 'netpr', 'ZERO_VALUE_INVALID',   0.0080, TRUE),
('ekpo_clean', 'netpr', 'OUT_OF_RANGE_HIGH',    0.0100, TRUE),
('ekpo_clean', 'netpr', 'EXTREME_OUTLIER',      0.0060, TRUE),
('ekpo_clean', 'netpr', 'ROUNDING_ERROR',       0.0120, TRUE),
('ekpo_clean', 'netpr', 'SCALE_DISTORTION',     0.0080, TRUE),

('ekpo_clean', 'peinh', 'NULLIFY_FIELD',        0.0030, TRUE),
('ekpo_clean', 'peinh', 'ZERO_VALUE_INVALID',   0.0080, TRUE),
('ekpo_clean', 'peinh', 'OUT_OF_RANGE_HIGH',    0.0060, TRUE),
('ekpo_clean', 'peinh', 'SCALE_DISTORTION',     0.0060, TRUE),

('ekpo_clean', 'netwr', 'NULLIFY_FIELD',        0.0040, TRUE),
('ekpo_clean', 'netwr', 'NEGATIVE_VALUE',       0.0080, TRUE),
('ekpo_clean', 'netwr', 'OUT_OF_RANGE_HIGH',    0.0080, TRUE),
('ekpo_clean', 'netwr', 'EXTREME_OUTLIER',      0.0050, TRUE),
('ekpo_clean', 'netwr', 'ROUNDING_ERROR',       0.0120, TRUE),
('ekpo_clean', 'netwr', 'VALUE_INCONSISTENCY',  0.0200, TRUE),

('ekpo_clean', NULL,    'DUPLICATE_RECORD',     0.0040, TRUE),
('ekpo_clean', NULL,    'MISSING_RECORD',       0.0030, TRUE),

-- =========================================================
-- MKPF_CLEAN
-- =========================================================
('mkpf_clean', 'mblnr', 'DUPLICATE_KEY',        0.0040, TRUE),
('mkpf_clean', 'mblnr', 'INVALID_FORMAT',       0.0060, TRUE),
('mkpf_clean', 'mblnr', 'TRUNCATED_VALUE',      0.0040, TRUE),

('mkpf_clean', 'mjahr', 'NULLIFY_FIELD',        0.0030, TRUE),
('mkpf_clean', 'mjahr', 'OUT_OF_RANGE_LOW',     0.0060, TRUE),
('mkpf_clean', 'mjahr', 'OUT_OF_RANGE_HIGH',    0.0060, TRUE),
('mkpf_clean', 'mjahr', 'SEMANTIC_DRIFT',       0.0060, TRUE),

('mkpf_clean', 'budat', 'NULLIFY_FIELD',        0.0050, TRUE),
('mkpf_clean', 'budat', 'INVALID_DATE',         0.0080, TRUE),
('mkpf_clean', 'budat', 'FUTURE_DATE',          0.0060, TRUE),
('mkpf_clean', 'budat', 'PAST_DATE_DRIFT',      0.0060, TRUE),

('mkpf_clean', NULL,    'DUPLICATE_RECORD',     0.0030, TRUE),
('mkpf_clean', NULL,    'MISSING_RECORD',       0.0020, TRUE),

-- =========================================================
-- MSEG_CLEAN
-- =========================================================
('mseg_clean', 'mblnr', 'NULLIFY_FIELD',        0.0040, TRUE),
('mseg_clean', 'mblnr', 'INVALID_FORMAT',       0.0060, TRUE),
('mseg_clean', 'mblnr', 'ORPHAN_REFERENCE',     0.0120, TRUE),

('mseg_clean', 'mjahr', 'NULLIFY_FIELD',        0.0030, TRUE),
('mseg_clean', 'mjahr', 'OUT_OF_RANGE_LOW',     0.0060, TRUE),
('mseg_clean', 'mjahr', 'OUT_OF_RANGE_HIGH',    0.0060, TRUE),

('mseg_clean', 'zeile', 'NULLIFY_FIELD',        0.0030, TRUE),
('mseg_clean', 'zeile', 'NON_UNIQUE_COMPOSITE', 0.0060, TRUE),
('mseg_clean', 'zeile', 'ZERO_VALUE_INVALID',   0.0040, TRUE),
('mseg_clean', 'zeile', 'OUT_OF_RANGE_HIGH',    0.0040, TRUE),

('mseg_clean', 'matnr', 'NULLIFY_FIELD',        0.0060, TRUE),
('mseg_clean', 'matnr', 'INVALID_FORMAT',       0.0070, TRUE),
('mseg_clean', 'matnr', 'ORPHAN_REFERENCE',     0.0140, TRUE),
('mseg_clean', 'matnr', 'SEMANTIC_DRIFT',       0.0100, TRUE),

('mseg_clean', 'werks', 'NULLIFY_FIELD',        0.0050, TRUE),
('mseg_clean', 'werks', 'INVALID_FORMAT',       0.0060, TRUE),
('mseg_clean', 'werks', 'ORPHAN_REFERENCE',     0.0120, TRUE),
('mseg_clean', 'werks', 'WRONG_FOREIGN_KEY',    0.0150, TRUE),

('mseg_clean', 'lgort', 'NULLIFY_FIELD',        0.0060, TRUE),
('mseg_clean', 'lgort', 'INVALID_FORMAT',       0.0070, TRUE),
('mseg_clean', 'lgort', 'WRONG_FOREIGN_KEY',    0.0120, TRUE),
('mseg_clean', 'lgort', 'SEMANTIC_DRIFT',       0.0080, TRUE),

('mseg_clean', 'kostl', 'NULLIFY_FIELD',        0.0070, TRUE),
('mseg_clean', 'kostl', 'INVALID_FORMAT',       0.0080, TRUE),
('mseg_clean', 'kostl', 'WRONG_FOREIGN_KEY',    0.0120, TRUE),

('mseg_clean', 'bwart', 'NULLIFY_FIELD',        0.0040, TRUE),
('mseg_clean', 'bwart', 'INVALID_FORMAT',       0.0070, TRUE),
('mseg_clean', 'bwart', 'SEMANTIC_DRIFT',       0.0100, TRUE),

('mseg_clean', 'menge', 'NULLIFY_FIELD',        0.0040, TRUE),
('mseg_clean', 'menge', 'NEGATIVE_VALUE',       0.0100, TRUE),
('mseg_clean', 'menge', 'ZERO_VALUE_INVALID',   0.0100, TRUE),
('mseg_clean', 'menge', 'OUT_OF_RANGE_HIGH',    0.0080, TRUE),
('mseg_clean', 'menge', 'EXTREME_OUTLIER',      0.0060, TRUE),
('mseg_clean', 'menge', 'ROUNDING_ERROR',       0.0100, TRUE),
('mseg_clean', 'menge', 'SCALE_DISTORTION',     0.0060, TRUE),

('mseg_clean', 'meins', 'NULLIFY_FIELD',        0.0040, TRUE),
('mseg_clean', 'meins', 'INVALID_FORMAT',       0.0060, TRUE),
('mseg_clean', 'meins', 'UNIT_MISMATCH',        0.0150, TRUE),
('mseg_clean', 'meins', 'SEMANTIC_DRIFT',       0.0080, TRUE),

('mseg_clean', 'dmbtr', 'NULLIFY_FIELD',        0.0040, TRUE),
('mseg_clean', 'dmbtr', 'NEGATIVE_VALUE',       0.0100, TRUE),
('mseg_clean', 'dmbtr', 'ZERO_VALUE_INVALID',   0.0080, TRUE),
('mseg_clean', 'dmbtr', 'OUT_OF_RANGE_HIGH',    0.0100, TRUE),
('mseg_clean', 'dmbtr', 'EXTREME_OUTLIER',      0.0060, TRUE),
('mseg_clean', 'dmbtr', 'ROUNDING_ERROR',       0.0120, TRUE),
('mseg_clean', 'dmbtr', 'VALUE_INCONSISTENCY',  0.0150, TRUE),

('mseg_clean', 'waers', 'NULLIFY_FIELD',        0.0050, TRUE),
('mseg_clean', 'waers', 'INVALID_FORMAT',       0.0070, TRUE),
('mseg_clean', 'waers', 'CURRENCY_MISMATCH',    0.0120, TRUE),

('mseg_clean', NULL,    'DUPLICATE_RECORD',     0.0040, TRUE),
('mseg_clean', NULL,    'MISSING_RECORD',       0.0030, TRUE),

-- =========================================================
-- RBKP_CLEAN
-- =========================================================
('rbkp_clean', 'belnr', 'DUPLICATE_KEY',        0.0040, TRUE),
('rbkp_clean', 'belnr', 'INVALID_FORMAT',       0.0060, TRUE),
('rbkp_clean', 'belnr', 'TRUNCATED_VALUE',      0.0040, TRUE),

('rbkp_clean', 'gjahr', 'NULLIFY_FIELD',        0.0030, TRUE),
('rbkp_clean', 'gjahr', 'OUT_OF_RANGE_LOW',     0.0060, TRUE),
('rbkp_clean', 'gjahr', 'OUT_OF_RANGE_HIGH',    0.0060, TRUE),

('rbkp_clean', 'bukrs', 'NULLIFY_FIELD',        0.0060, TRUE),
('rbkp_clean', 'bukrs', 'INVALID_FORMAT',       0.0060, TRUE),
('rbkp_clean', 'bukrs', 'WRONG_FOREIGN_KEY',    0.0100, TRUE),

('rbkp_clean', 'lifnr', 'NULLIFY_FIELD',        0.0080, TRUE),
('rbkp_clean', 'lifnr', 'INVALID_FORMAT',       0.0070, TRUE),
('rbkp_clean', 'lifnr', 'ORPHAN_REFERENCE',     0.0120, TRUE),
('rbkp_clean', 'lifnr', 'WRONG_FOREIGN_KEY',    0.0100, TRUE),

('rbkp_clean', 'bldat', 'NULLIFY_FIELD',        0.0060, TRUE),
('rbkp_clean', 'bldat', 'INVALID_DATE',         0.0080, TRUE),
('rbkp_clean', 'bldat', 'FUTURE_DATE',          0.0060, TRUE),
('rbkp_clean', 'bldat', 'PAST_DATE_DRIFT',      0.0060, TRUE),

('rbkp_clean', 'budat', 'NULLIFY_FIELD',        0.0060, TRUE),
('rbkp_clean', 'budat', 'INVALID_DATE',         0.0080, TRUE),
('rbkp_clean', 'budat', 'FUTURE_DATE',          0.0060, TRUE),
('rbkp_clean', 'budat', 'PAST_DATE_DRIFT',      0.0060, TRUE),
('rbkp_clean', 'budat', 'DATE_ORDER_VIOLATION', 0.0120, TRUE),

('rbkp_clean', 'waers', 'NULLIFY_FIELD',        0.0050, TRUE),
('rbkp_clean', 'waers', 'INVALID_FORMAT',       0.0070, TRUE),
('rbkp_clean', 'waers', 'CURRENCY_MISMATCH',    0.0100, TRUE),

('rbkp_clean', NULL,    'DUPLICATE_RECORD',     0.0030, TRUE),
('rbkp_clean', NULL,    'MISSING_RECORD',       0.0020, TRUE),

-- =========================================================
-- RSEG_CLEAN
-- =========================================================
('rseg_clean', 'belnr', 'NULLIFY_FIELD',        0.0040, TRUE),
('rseg_clean', 'belnr', 'INVALID_FORMAT',       0.0060, TRUE),
('rseg_clean', 'belnr', 'ORPHAN_REFERENCE',     0.0120, TRUE),

('rseg_clean', 'gjahr', 'NULLIFY_FIELD',        0.0030, TRUE),
('rseg_clean', 'gjahr', 'OUT_OF_RANGE_LOW',     0.0060, TRUE),
('rseg_clean', 'gjahr', 'OUT_OF_RANGE_HIGH',    0.0060, TRUE),

('rseg_clean', 'buzei', 'NULLIFY_FIELD',        0.0030, TRUE),
('rseg_clean', 'buzei', 'NON_UNIQUE_COMPOSITE', 0.0060, TRUE),
('rseg_clean', 'buzei', 'ZERO_VALUE_INVALID',   0.0040, TRUE),
('rseg_clean', 'buzei', 'OUT_OF_RANGE_HIGH',    0.0040, TRUE),

('rseg_clean', 'ebeln', 'NULLIFY_FIELD',        0.0040, TRUE),
('rseg_clean', 'ebeln', 'INVALID_FORMAT',       0.0060, TRUE),
('rseg_clean', 'ebeln', 'ORPHAN_REFERENCE',     0.0120, TRUE),

('rseg_clean', 'ebelp', 'NULLIFY_FIELD',        0.0030, TRUE),
('rseg_clean', 'ebelp', 'NON_UNIQUE_COMPOSITE', 0.0060, TRUE),
('rseg_clean', 'ebelp', 'ZERO_VALUE_INVALID',   0.0040, TRUE),
('rseg_clean', 'ebelp', 'OUT_OF_RANGE_HIGH',    0.0040, TRUE),

('rseg_clean', 'matnr', 'NULLIFY_FIELD',        0.0060, TRUE),
('rseg_clean', 'matnr', 'INVALID_FORMAT',       0.0070, TRUE),
('rseg_clean', 'matnr', 'ORPHAN_REFERENCE',     0.0140, TRUE),
('rseg_clean', 'matnr', 'SEMANTIC_DRIFT',       0.0100, TRUE),

('rseg_clean', 'menge', 'NULLIFY_FIELD',        0.0040, TRUE),
('rseg_clean', 'menge', 'NEGATIVE_VALUE',       0.0100, TRUE),
('rseg_clean', 'menge', 'ZERO_VALUE_INVALID',   0.0100, TRUE),
('rseg_clean', 'menge', 'OUT_OF_RANGE_HIGH',    0.0080, TRUE),
('rseg_clean', 'menge', 'EXTREME_OUTLIER',      0.0060, TRUE),
('rseg_clean', 'menge', 'ROUNDING_ERROR',       0.0100, TRUE),
('rseg_clean', 'menge', 'SCALE_DISTORTION',     0.0060, TRUE),

('rseg_clean', 'meins', 'NULLIFY_FIELD',        0.0040, TRUE),
('rseg_clean', 'meins', 'INVALID_FORMAT',       0.0060, TRUE),
('rseg_clean', 'meins', 'UNIT_MISMATCH',        0.0150, TRUE),
('rseg_clean', 'meins', 'SEMANTIC_DRIFT',       0.0080, TRUE),

('rseg_clean', 'wrbtr', 'NULLIFY_FIELD',        0.0040, TRUE),
('rseg_clean', 'wrbtr', 'NEGATIVE_VALUE',       0.0100, TRUE),
('rseg_clean', 'wrbtr', 'ZERO_VALUE_INVALID',   0.0080, TRUE),
('rseg_clean', 'wrbtr', 'OUT_OF_RANGE_HIGH',    0.0100, TRUE),
('rseg_clean', 'wrbtr', 'EXTREME_OUTLIER',      0.0060, TRUE),
('rseg_clean', 'wrbtr', 'ROUNDING_ERROR',       0.0120, TRUE),
('rseg_clean', 'wrbtr', 'VALUE_INCONSISTENCY',  0.0150, TRUE),

('rseg_clean', NULL,    'DUPLICATE_RECORD',     0.0040, TRUE),
('rseg_clean', NULL,    'MISSING_RECORD',       0.0030, TRUE);
