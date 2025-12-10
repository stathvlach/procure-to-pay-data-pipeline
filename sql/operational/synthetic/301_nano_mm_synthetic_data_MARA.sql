--================================================================================================
-- Script: 301_nano_mm_synthetic_data_MARA.sql
-- Purpose:
--     Generate synthetic material master data (table: MARA) using configuration tables for
--     material types (T134), material groups (T023), and units of measure (T006).
--
-- Description:
--     - Truncates the MARA table and reinitializes the material-number sequence.
--     - Produces a fixed number of synthetic material records (~1000 by default).
--     - Material types (MTART) are sourced dynamically from T134 and assigned in a
--       round-robin fashion to ensure uniform distribution across all configured types.
--
--     - Material groups (MATKL) from T023 and base units of measure (MEINS) from T006
--       are also assigned via modulo-based cyclic distribution, ensuring:
--         * Even usage of all configured material groups,
--         * Even usage of all defined units of measure,
--         * Reproducible, deterministic synthetic generation.
--
-- Dependencies:
--     * T134 must contain at least one material type (MTART).
--     * T023 must contain valid material groups (MATKL).
--     * T006 must contain valid units of measure (MEINS).
--     * Sequence: mara_matnr_seq (recreated in this script).
--
-- Output:
--     - Populates MARA with synthetic but structurally accurate master material records,
--       consistent with SAP-style material master modeling.
--
-- Notes:
--     - Adjust total_materials in the CTE "params" as needed.
--================================================================================================
TRUNCATE TABLE mara CASCADE;

DROP SEQUENCE IF EXISTS mara_matnr_seq;
CREATE SEQUENCE mara_matnr_seq START 1;

WITH params AS (
    SELECT 1000::int AS total_materials
),

-- Material types config table T134
t134_types AS (
    SELECT
        mtart,
        ROW_NUMBER() OVER (ORDER BY mtart) AS rn,
        COUNT(*)  OVER ()                  AS cnt
    FROM (
        SELECT DISTINCT mtart
        FROM t134
    ) AS x
),

-- Μmaterial group config table T023
mat_groups AS (
    SELECT
        matkl,
        ROW_NUMBER() OVER (ORDER BY matkl) AS rn,
        COUNT(*)  OVER ()                  AS cnt
    FROM (
        SELECT DISTINCT matkl
        FROM t023
    ) AS x
),

-- UoM config table T006
uom AS (
    SELECT
        meins,
        ROW_NUMBER() OVER (ORDER BY meins) AS rn,
        COUNT(*)  OVER ()                  AS cnt
    FROM (
        SELECT DISTINCT meins
        FROM t006
    ) AS x
),

materials AS (
    SELECT
        ROW_NUMBER() OVER ()                                   AS rn,
        lpad(nextval('mara_matnr_seq')::text, 8, '0')          AS matnr
    FROM params p
    CROSS JOIN generate_series(1, p.total_materials) AS g
),

materials_with_types AS (
    SELECT
        m.rn,
        m.matnr,
        t.mtart
    FROM materials m
    JOIN t134_types t
      ON ((m.rn - 1) % t.cnt) + 1 = t.rn
)

INSERT INTO mara (matnr, mtart, matkl, meins)
SELECT
    m.matnr,
    m.mtart,
    mg.matkl,
    u.meins
FROM materials_with_types m
JOIN mat_groups mg
  ON ((m.rn - 1) % mg.cnt) + 1 = mg.rn
JOIN uom u
  ON ((m.rn - 1) % u.cnt) + 1 = u.rn
;
