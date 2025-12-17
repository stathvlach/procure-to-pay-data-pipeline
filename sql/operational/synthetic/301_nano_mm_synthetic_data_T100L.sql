--================================================================================================
-- Script: 301_nano_mm_synthetic_data_T001L.sql
-- Purpose:
--     Generate synthetic storage location master data (table: T001L) per plant.
--
-- Description:
--     - Produces a controlled number of storage locations (LGORT) for each plant (WERKS).
--     - Storage locations are generated deterministically (e.g. 0001–000N).
--
-- Dependencies:
--     * Table T001W must be populated with valid plant codes (WERKS).
--
-- Output:
--     - Populates T001L with synthetic but structurally accurate storage location master data,
--       aligned with SAP inventory management modeling practices.
--
-- Notes:
--     - Adjust the number of storage locations per plant via the parameters CTE as needed.
--================================================================================================

SET search_path TO operational;

TRUNCATE TABLE t001l CASCADE;

WITH params AS (
    SELECT 6::int AS lgorts_per_plant  -- π.χ. 6 LGORT ανά plant
),
plants AS (
    SELECT
        werks,
        ROW_NUMBER() OVER (ORDER BY werks) AS rn_w
    FROM t001w
),
lgorts AS (
    SELECT
        gs AS idx,
        LPAD(gs::text, 4, '0') AS lgort
    FROM params p
    CROSS JOIN generate_series(1, p.lgorts_per_plant) AS gs
)
INSERT INTO t001l (werks, lgort)
SELECT
    p.werks,
    l.lgort
FROM plants p
CROSS JOIN lgorts l
;
