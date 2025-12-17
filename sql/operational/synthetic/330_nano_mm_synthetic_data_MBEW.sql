--================================================================================================
-- Script: 330_nano_mm_synthetic_data_MBEW.sql
-- Purpose:
--     Generate synthetic material valuation data (table: MBEW) using:
--         - MARA (materials)
--         - T001W (plants as valuation areas; BWKEY == WERKS)
--
-- Description:
--     - Truncates MBEW.
--     - Creates candidate pairs (MATNR, BWKEY) from MARA x T001W.
--     - Keeps only a controlled percentage of combinations (coverage_pct) to control volume.
--     - Generates deterministic, non-negative valuation values:
--         * STPRS (standard price) as NUMERIC(11,2), with price ranges tied to MARA-MEINS
--           and a skewed distribution (many low prices, few high prices).
--         * PEINH (price unit) selected equal to 1 for simplicity.
--
-- Dependencies:
--     * MARA must be populated (MATNR, MEINS).
--     * T001W must be populated (WERKS).
--     * PK: MBEW(MATNR, BWKEY), FKs to MARA and T001W as defined.
--
-- Notes:
--     - Adjust coverage_pct, skew_power, and UoM-specific price bands as needed.
--================================================================================================

SET search_path TO operational;

TRUNCATE TABLE mbew CASCADE;

WITH params AS (
    SELECT
        35::int       AS coverage_pct,     -- % of (MARA x T001W) kept
        2.4::numeric  AS skew_power        -- >1 => more low prices, fewer high prices
),
materials AS (
    SELECT matnr, meins
    FROM mara
),
plants AS (
    SELECT werks AS bwkey
    FROM t001w
),
pairs AS (
    SELECT
        m.matnr,
        m.meins,
        p.bwkey,
        ROW_NUMBER() OVER (ORDER BY m.matnr, p.bwkey) AS rn
    FROM materials m
    CROSS JOIN plants p
),
pairs_kept AS (
    SELECT *
    FROM pairs pk
    CROSS JOIN params par
    WHERE (pk.rn % 100) < par.coverage_pct
),

-- PEINH domain (SAP-ish): price per 1 / 10 / 100 / 1000 units
peinh_domain AS (
    SELECT
        v.peinh,
        ROW_NUMBER() OVER (ORDER BY v.peinh) AS rn,
        COUNT(*) OVER () AS cnt
    FROM (VALUES (1::numeric), (10::numeric), (100::numeric), (1000::numeric)) AS v(peinh)
),
-- Price bands per UoM (based on your T006 MEINS set)
uom_price_bands AS (
    SELECT
        pk.*,

        CASE
            -- discrete items
            WHEN pk.meins IN ('EA','PCE','SET') THEN 0.50::numeric
            -- packaging units
            WHEN pk.meins IN ('PK','BOX','BAG') THEN 2.00::numeric
            WHEN pk.meins IN ('ROL')           THEN 1.50::numeric
            WHEN pk.meins IN ('PAL')           THEN 20.00::numeric

            -- weight
            WHEN pk.meins IN ('KG')            THEN 0.80::numeric
            WHEN pk.meins IN ('G')             THEN 0.01::numeric

            -- volume
            WHEN pk.meins IN ('L')             THEN 0.60::numeric
            WHEN pk.meins IN ('ML')            THEN 0.01::numeric

            -- length
            WHEN pk.meins IN ('M')             THEN 0.40::numeric
            WHEN pk.meins IN ('CM','MM')       THEN 0.01::numeric

            ELSE 0.50::numeric
        END AS p_min,

        CASE
            -- discrete items
            WHEN pk.meins IN ('EA','PCE','SET') THEN 800.00::numeric
            -- packaging
            WHEN pk.meins IN ('PK','BOX','BAG') THEN 200.00::numeric
            WHEN pk.meins IN ('ROL')           THEN 300.00::numeric
            WHEN pk.meins IN ('PAL')           THEN 5000.00::numeric

            -- weight
            WHEN pk.meins IN ('KG')            THEN 250.00::numeric
            WHEN pk.meins IN ('G')             THEN 5.00::numeric

            -- volume
            WHEN pk.meins IN ('L')             THEN 180.00::numeric
            WHEN pk.meins IN ('ML')            THEN 3.00::numeric

            -- length
            WHEN pk.meins IN ('M')             THEN 220.00::numeric
            WHEN pk.meins IN ('CM','MM')       THEN 2.00::numeric

            ELSE 400.00::numeric
        END AS p_max
    FROM pairs_kept pk
),

final_rows AS (
    SELECT
        b.matnr,
        b.bwkey,

        -- u in [0,1] (deterministic), then skew with power() => many low, few high
        -- unit_price in [p_min, p_max]
        (
          b.p_min
          + power(
              (
                (
                  (('x' || substring(md5(b.matnr || '|' || b.bwkey), 1, 8))::bit(32)::int & x'7fffffff'::int)
                )::numeric / 2147483647::numeric
              ),
              (SELECT skew_power FROM params)
            )
            * (b.p_max - b.p_min)
        ) AS unit_price
    FROM uom_price_bands b
)

INSERT INTO mbew (matnr, bwkey, stprs, peinh)
SELECT
    matnr,
    bwkey,
    round(unit_price, 2) AS stprs,
    1::numeric AS peinh
FROM final_rows
;
