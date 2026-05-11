-- =====================================================================
-- Project : Procure-to-Pay Data Platform
-- Layer   : bootstrap
-- Folder  : synthetic
-- File    : 310_generate_EKPO_clean.sql
--
-- Purpose:
--   Generate clean purchase order item (EKPO) data representing
--   valid, well-formed external source system output.
--
-- Description:
--   This script generates a synthetic but semantically valid dataset
--   for purchase order items (EKPO). The generated data represents
--   the expected output of an external procurement system under normal
--   operating conditions, without data quality issues or corruption.
--
--   The dataset produced here serves as the "clean" baseline used to:
--     - Export landing files (CSV / JSON / XML), and
--     - Act as input for controlled corruption scenarios defined
--       in subsequent bootstrap scripts.
--
--   No corruption rules are applied in this script. All records comply
--   with expected structural and business-level constraints.
--
-- Inputs:
--   Reference and master data from the operational schema, including:
--     - Company codes
--     - Vendors
--     - Purchasing organizations and document types
--
-- Outputs:
--   Clean synthetic EKPO dataset, persisted temporarily within the
--   bootstrap schema and/or exported as landing files.
--
-- Execution Context:
--   Executed as part of the bootstrap synthetic data generation workflow.
--   Typically run prior to the corresponding corrupted data generator.
--
-- Notes:
--   This script intentionally does not enforce relational constraints
--   to downstream documents (EKPO, MSEG, RSEG). Such relationships are
--   resolved later in the data pipeline.
--
-- Author: Stathis Vlachos
-- =====================================================================

TRUNCATE TABLE bootstrap.ekpo_clean;

WITH
params AS (
    SELECT
        0.20::numeric AS top_vendor_share,
        4::int  AS top_items_min,
        14::int  AS top_items_max,
        1::int  AS rest_items_min,
        9::int  AS rest_items_max
),

vendor_po_counts AS (
    SELECT
        lifnr,
        COUNT(*)::int AS po_cnt
    FROM bootstrap.ekko_clean
    GROUP BY lifnr
),

vendor_ranked AS (
    SELECT
        lifnr,
        po_cnt,
        ROW_NUMBER() OVER (ORDER BY po_cnt DESC, lifnr) AS rnk,
        COUNT(*) OVER () AS n_vendors
    FROM vendor_po_counts
),

top_vendor_cutoff AS (
    SELECT
        GREATEST(1, CEIL(n_vendors * (SELECT top_vendor_share FROM params))::int) AS n_top_vendors
    FROM vendor_ranked
    LIMIT 1
),

top_vendors AS (
    SELECT vr.lifnr
    FROM vendor_ranked vr
    WHERE vr.rnk <= (SELECT n_top_vendors FROM top_vendor_cutoff)
),

ekko_classified AS (
    SELECT
        e.ebeln,
        e.lifnr,
        CASE
	        WHEN tv.lifnr IS NOT NULL THEN 1
        	ELSE 0
        END AS is_top_vendor_po
    FROM bootstrap.ekko_clean e
    LEFT JOIN top_vendors tv
      ON tv.lifnr = e.lifnr
),

materials AS (
    SELECT
        m.matnr,
        m.meins,
        ROW_NUMBER() OVER (ORDER BY m.matnr) AS rn
    FROM operational.mara m
),

mc AS (
	SELECT COUNT(*)::int AS n_mat FROM materials
),

plants AS (
    SELECT
        w.werks,
        ROW_NUMBER() OVER (ORDER BY w.werks) AS rn
    FROM operational.t001w w
),

pc AS (
	SELECT COUNT(*)::int AS n_plants FROM plants
),

po_item_counts AS (
    SELECT
        ec.ebeln,
        ec.is_top_vendor_po,
CASE
  WHEN ec.is_top_vendor_po = 1 THEN
    (SELECT top_items_min FROM params)
    + (
        (
          (
            (('x' || substr(md5(ec.ebeln || '|items_top'), 1, 8))::bit(32)::int)
            & x'7FFFFFFF'::int
          )
          % (
              (SELECT top_items_max FROM params)
              - (SELECT top_items_min FROM params)
              + 1
            )
        )
      )
  ELSE
    (SELECT rest_items_min FROM params)
    + (
        (
          (
            (('x' || substr(md5(ec.ebeln || '|items_rest'), 1, 8))::bit(32)::int)
            & x'7FFFFFFF'::int
          )
          % (
              (SELECT rest_items_max FROM params)
              - (SELECT rest_items_min FROM params)
              + 1
            )
        )
      )
END AS n_items
    FROM ekko_classified ec
),

items_expanded AS (
    SELECT
        pic.ebeln,
        gs.i AS item_idx,
        (gs.i * 10) AS ebelp
    FROM po_item_counts pic
    CROSS JOIN LATERAL generate_series(1, pic.n_items) AS gs(i)
),

items_with_masterdata AS (
    SELECT
        ie.ebeln,
        ie.ebelp,

        mat.matnr,
        mat.meins,
        pl.werks,

        ROUND((1 + (random() * 199))::numeric, 3) AS menge,
        ROUND((1 + (random() * 499))::numeric, 2) AS netpr,
        1::numeric(5,0) AS peinh
    FROM items_expanded ie
    CROSS JOIN mc
    CROSS JOIN pc
    JOIN materials mat
      ON mat.rn = ((('x' || substr(md5(ie.ebeln || '|' || ie.ebelp::text || '|mat'), 1, 8))::bit(32)::int % mc.n_mat) +
1)
    JOIN plants pl
      ON pl.rn = ((('x' || substr(md5(ie.ebeln || '|' || ie.ebelp::text || '|pl'), 1, 8))::bit(32)::int % pc.n_plants) +
1)
)

INSERT INTO bootstrap.ekpo_clean (ebeln, ebelp, matnr, werks, menge, meins, netpr, peinh, netwr)
SELECT
    ebeln,
    ebelp,
    matnr,
    werks,
    menge,
    meins,
    netpr,
    peinh,
    ROUND((menge * netpr / NULLIF(peinh, 0))::numeric, 2) AS netwr
FROM items_with_masterdata
;
