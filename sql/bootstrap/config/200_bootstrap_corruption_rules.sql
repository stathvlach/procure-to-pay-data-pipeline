-- =====================================================================
-- Project : Procure-to-Pay Data Platform
-- Layer   : bootstrap
-- Folder  : config
-- File    : 200_bootstrap_corruption_rules.sql
--
-- Purpose:
--   Seed the bootstrap corruption rule catalog used to describe supported
--   data-quality corruption patterns for synthetic data generation.
--
-- Description:
--   This script populates the bootstrap-level rule catalog, defining the
--   available corruption rule types that may be applied to transactional
--   datasets (EKKO, EKPO, MKPF, MSEG, RBKP, RSEG).
--
--   The rule catalog is a stable reference list (rule definitions), while
--   rule application (per table, intensity, and parameters) is configured
--   separately via table-specific configuration scripts.
--
-- Inputs:
--   None.
--
-- Outputs:
--   Seed data inserted into:
--     - bootstrap.corruption_rule
--
-- Execution Context:
--   Executed during environment setup / re-seeding of the bootstrap layer.
--   Typically run after bootstrap tables have been created.
--
-- Notes :
--   - The catalog is intended to be relatively static; new rules may be
--     added incrementally as new corruption scenarios are introduced.
--   - This script should be idempotent (e.g., INSERT...ON CONFLICT DO NOTHING)
--     to support repeated development runs.
--
-- Author : Stathis Vlachos
-- =====================================================================


--
INSERT INTO bootstrap.corruption_rule (rule_code, description, rule_category) VALUES

-- =========================
-- NULLS
-- =========================
('NULLIFY_FIELD', 'Set field value to NULL', 'NULLS'),
('PARTIAL_NULLIFY_GROUP', 'Nullify one field within a dependent field group', 'NULLS'),

-- =========================
-- RANGE / NUMERIC
-- =========================
('NEGATIVE_VALUE', 'Introduce negative value where only positive is valid', 'RANGE'),
('ZERO_VALUE_INVALID', 'Set value to zero where zero is not allowed', 'RANGE'),
('OUT_OF_RANGE_HIGH', 'Set value above allowed maximum', 'RANGE'),
('OUT_OF_RANGE_LOW', 'Set value below allowed minimum', 'RANGE'),
('EXTREME_OUTLIER', 'Inject extreme numeric outlier', 'RANGE'),
('SCALE_DISTORTION', 'Change magnitude (e.g. *10, /100)', 'RANGE'),
('ROUNDING_ERROR', 'Introduce rounding inconsistency', 'RANGE'),

-- =========================
-- FORMAT
-- =========================
('INVALID_FORMAT', 'Break expected format pattern', 'FORMAT'),
('TRUNCATED_VALUE', 'Cut value length below expected', 'FORMAT'),
('OVERFLOW_LENGTH', 'Exceed maximum allowed length', 'FORMAT'),
('PADDING_ERROR', 'Add incorrect padding (leading/trailing)', 'FORMAT'),
('INVALID_CHARACTER', 'Inject invalid/special characters', 'FORMAT'),
('CASE_MISMATCH', 'Alter case sensitivity (upper/lower)', 'FORMAT'),

-- =========================
-- KEYS & IDENTIFIERS
-- =========================
('DUPLICATE_KEY', 'Duplicate primary or business key', 'DUPLICATES'),
('KEY_COLLISION', 'Force collision between distinct entities', 'DUPLICATES'),
('NON_UNIQUE_COMPOSITE', 'Break composite key uniqueness', 'DUPLICATES'),

-- =========================
-- REFERENTIAL INTEGRITY
-- =========================
('ORPHAN_REFERENCE', 'Reference non-existing parent record', 'REFERENTIAL'),
('WRONG_FOREIGN_KEY', 'Assign valid but incorrect foreign key', 'REFERENTIAL'),
('CROSS_ENTITY_MISMATCH', 'Mismatch related entities (e.g. vendor vs company)', 'REFERENTIAL'),

-- =========================
-- CONSISTENCY (CROSS-FIELD)
-- =========================
('VALUE_INCONSISTENCY', 'Break arithmetic relation (e.g. qty * price != value)', 'CONSISTENCY'),
('UNIT_MISMATCH', 'Mismatch unit of measure vs quantity/price', 'CONSISTENCY'),
('CURRENCY_MISMATCH', 'Inconsistent currency across related fields', 'CONSISTENCY'),
('DEPENDENCY_VIOLATION', 'Break dependency between fields', 'CONSISTENCY'),

-- =========================
-- TEMPORAL
-- =========================
('INVALID_DATE', 'Set invalid or non-parsable date', 'TEMPORAL'),
('FUTURE_DATE', 'Shift date unrealistically into the future', 'TEMPORAL'),
('PAST_DATE_DRIFT', 'Shift date unrealistically into the past', 'TEMPORAL'),
('DATE_ORDER_VIOLATION', 'Break logical date order (e.g. delivery < order)', 'TEMPORAL'),

-- =========================
-- DISTRIBUTION / STATISTICAL
-- =========================
('SKEW_DISTRIBUTION', 'Bias distribution toward subset of values', 'DISTRIBUTION'),
('RARE_VALUE_SPIKE', 'Inject rare values with abnormal frequency', 'DISTRIBUTION'),

-- =========================
-- TEXT / SEMANTIC
-- =========================
('RANDOM_NOISE', 'Replace value with random noise', 'TEXT'),
('SEMANTIC_DRIFT', 'Replace with plausible but incorrect value', 'TEXT'),
('TOKEN_SWAP', 'Swap tokens within structured string', 'TEXT'),

-- =========================
-- STRUCTURAL / RECORD LEVEL
-- =========================
('MISSING_RECORD', 'Simulate missing expected record', 'STRUCTURAL'),
('DUPLICATE_RECORD', 'Duplicate entire record', 'STRUCTURAL'),
('PARTIAL_RECORD', 'Remove subset of required fields', 'STRUCTURAL');
