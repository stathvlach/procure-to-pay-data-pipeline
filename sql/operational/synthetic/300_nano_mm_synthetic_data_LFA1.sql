--================================================================================================
-- Script: 300_nano_mm_synthetic_data_lfa1.sql
-- Purpose:
--     Generate synthetic vendor master data (table: LFA1) using weighted country distributions.
--
-- Description:
--     - Truncates and reinitializes the vendor table (LFA1) and its sequence.
--     - Produces a fixed number of synthetic vendor records (~500 by default).
--     - Assigns countries according to controlled distribution weights:
--         * GR: ~40%
--         * DE: ~20%
--         * IT: ~10%
--         * Other countries (from table T005): ~30% distributed evenly via modulo pattern.
--
-- Dependencies:
--     * Table T005 must contain valid country codes including at least GR, DE, and IT.
--     * Sequence: lfa1_lifnr_seq (recreated in this script).
--
-- Output:
--     - Populates table LFA1 with synthetic but realistically distributed vendor master data.
--
-- Notes:
--     - Adjust the total_vendors parameter in the CTE "params" as needed.
--================================================================================================

TRUNCATE TABLE lfa1 CASCADE;

DROP SEQUENCE IF EXISTS lfa1_lifnr_seq;
CREATE SEQUENCE lfa1_lifnr_seq START 1;

WITH params AS (
    SELECT 500::int AS total_vendors
),
weights AS (
    SELECT
        total_vendors,
        round(total_vendors * 0.40)::int AS n_gr,
        round(total_vendors * 0.20)::int AS n_de,
        round(total_vendors * 0.10)::int AS n_it
    FROM params
),
counts AS (
    SELECT
        total_vendors,
        n_gr,
        n_de,
        n_it,
        (total_vendors - (n_gr + n_de + n_it)) AS n_oth
    FROM weights
),
other_countries AS (
    SELECT
        land1,
        ROW_NUMBER() OVER (ORDER BY land1) AS rn,
        COUNT(*) OVER ()                  AS cnt
    FROM (
        SELECT DISTINCT land1
        FROM t005
        WHERE land1 NOT IN ('GR', 'DE', 'IT')
    ) AS x
)

INSERT INTO lfa1 (lifnr, name1, land1)
SELECT
    lifnr,
    'Vendor ' || lifnr AS name1,
    land1
FROM (
    -- GR: ~40%
    SELECT
        lpad(nextval('lfa1_lifnr_seq')::text, 10, '0') AS lifnr,
        'GR'::varchar(3)                                AS land1
    FROM counts c
    CROSS JOIN generate_series(1, c.n_gr) AS g

    UNION ALL

    -- DE: ~20%
    SELECT
        lpad(nextval('lfa1_lifnr_seq')::text, 10, '0') AS lifnr,
        'DE'::varchar(3)                                AS land1
    FROM counts c
    CROSS JOIN generate_series(1, c.n_de) AS g

    UNION ALL

    -- IT: ~10%
    SELECT
        lpad(nextval('lfa1_lifnr_seq')::text, 10, '0') AS lifnr,
        'IT'::varchar(3)                                AS land1
    FROM counts c
    CROSS JOIN generate_series(1, c.n_it) AS g

    UNION ALL

    -- Other countries: ~30%
    SELECT
        lpad(nextval('lfa1_lifnr_seq')::text, 10, '0') AS lifnr,
        oc.land1                                       AS land1
    FROM counts c
    JOIN generate_series(1, c.n_oth) AS g(i)
      ON TRUE
    JOIN other_countries oc
      ON ((g.i - 1) % oc.cnt) + 1 = oc.rn
);
