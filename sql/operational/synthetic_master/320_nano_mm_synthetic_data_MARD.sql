--================================================================================================
-- Script: 320_nano_mm_synthetic_data_MARD.sql
-- Purpose:
--     Generate synthetic storage-location stock data (table: MARD) using:
--         - MARA (materials)
--         - T001L (storage locations per plant)
--
-- Description:
--     - Truncates MARD.
--     - Creates candidate pairs (MATNR, WERKS, LGORT) from MARA x T001L.
--     - Keeps only a controlled percentage of combinations (coverage_pct) to control volume.
--     - Generates deterministic, non-negative LABST values as NUMERIC(13,3).
--
-- Dependencies:
--     * MARA must be populated (MATNR).
--     * T001L must be populated (WERKS, LGORT).
--
-- Notes:
--     - Adjust coverage_pct and labst_max_int in params as needed.
--================================================================================================

SET search_path TO operational;

TRUNCATE TABLE mard CASCADE;

WITH params AS (
    SELECT
        35::int    AS coverage_pct,   -- % of (MARA x T001L) combinations kept
        20000::int AS labst_max_int   -- max integer part of LABST
),
materials AS (
    SELECT
        matnr,
        ROW_NUMBER() OVER (ORDER BY matnr) AS rn_m
    FROM mara
),
slocs AS (
    SELECT
        werks,
        lgort,
        ROW_NUMBER() OVER (ORDER BY werks, lgort) AS rn_s
    FROM t001l
),
-- All possible (matnr, werks, lgort) triples
combos AS (
    SELECT
        m.matnr,
        s.werks,
        s.lgort,
        ROW_NUMBER() OVER (ORDER BY m.matnr, s.werks, s.lgort) AS rn
    FROM materials m
    CROSS JOIN slocs s
),
-- Deterministic down-sampling
combos_kept AS (
    SELECT
        *
    FROM combos c
    CROSS JOIN params p
    WHERE (c.rn % 100) < p.coverage_pct
),
-- Deterministic NUMERIC(13,3) LABST, always >= 0
final_rows AS (
    SELECT
        ck.matnr,
        ck.werks,
        ck.lgort,
-- Deterministic pseudo-random generator:
-- We derive numeric values from an md5 hash of business keys (MATNR, WERKS, LGORT)
-- to produce stable, reproducible quantities without relying on random() or sequences.
        (
            (
              ('x' || SUBSTRING(md5(ck.matnr || '|' || ck.werks || '|' || ck.lgort), 1, 5))::bit(32)::int & x'ffff'::int
            ) % (SELECT labst_max_int FROM params)
        )::numeric(13,3)
        +
        (
            (
              ('x' || SUBSTRING(md5(ck.lgort || '|' || ck.matnr), 1, 4))::bit(24)::int & x'fff'::int
            ) % 1000
        )::numeric / 1000
        AS labst
    FROM combos_kept ck
)
INSERT INTO mard (matnr, werks, lgort, labst)
SELECT
    matnr,
    werks,
    lgort,
    labst
FROM final_rows
;
