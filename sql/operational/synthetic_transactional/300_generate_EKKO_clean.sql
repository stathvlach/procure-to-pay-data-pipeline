-- =====================================================================
-- Project : Procure-to-Pay Data Platform
-- Layer   : bootstrap
-- Folder  : synthetic
-- File    : 300_generate_EKKO_clean.sql
--
-- Purpose:
--   Generate clean purchase order header (EKKO) data representing
--   valid, well-formed external source system output.
--
-- Description:
--   This script generates a synthetic but semantically valid dataset
--   for purchase order header (EKKO). The generated data represents
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
--   Clean synthetic EKKO dataset, persisted temporarily within the
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


CREATE SEQUENCE IF NOT EXISTS bootstrap.ekko_ebeln_seq
    START 4500000000
    INCREMENT 1;

TRUNCATE TABLE bootstrap.ekko_clean;

WITH
params AS (
    SELECT
        1200::int AS total_pos,
        0.70::numeric AS top_share,
        0.20::numeric AS top_vendor_share
),

-- vendor list with stable ordering
vendors AS (
    SELECT lifnr, ROW_NUMBER() OVER (ORDER BY md5(lifnr || '|seed:ekko_vendors_v1')) AS rn
    FROM operational.lfa1
),
vc AS (
    SELECT COUNT(*)::int AS n_vendors FROM vendors
),

-- derive exact counts
counts AS (
    SELECT
        p.total_pos,
        (p.total_pos * p.top_share)::int AS n_top_pos,
        (p.total_pos - (p.total_pos * p.top_share)::int) AS n_rest_pos,

        LEAST((vc.n_vendors * p.top_vendor_share)::int, vc.n_vendors) AS n_top_vendors,
        GREATEST(vc.n_vendors - LEAST((vc.n_vendors * p.top_vendor_share)::int, vc.n_vendors), 0) AS n_rest_vendors
    FROM params p
    CROSS JOIN vc
),

top_vendors AS (
    SELECT lifnr, ROW_NUMBER() OVER (ORDER BY rn) AS idx
    FROM vendors
    WHERE rn <= (SELECT n_top_vendors FROM counts)
),

rest_vendors AS (
    SELECT lifnr, ROW_NUMBER() OVER (ORDER BY rn) AS idx
    FROM vendors
    WHERE rn > (SELECT n_top_vendors FROM counts)
),

top_pos AS (
    SELECT
        LPAD(nextval('bootstrap.ekko_ebeln_seq')::text, 10, '0') AS ebeln,
        '1000'::varchar(4) AS bukrs,
        tv.lifnr,
        CURRENT_DATE - (random() * 365 * 3)::int AS bedat,
        'EUR'::varchar(5) AS waers
    FROM counts c
    CROSS JOIN generate_series(1, c.n_top_pos) g(i)
    JOIN top_vendors tv
      ON tv.idx = ((g.i - 1) % NULLIF((SELECT n_top_vendors FROM counts), 0)) + 1
),


rest_pos AS (
    SELECT
        LPAD(nextval('bootstrap.ekko_ebeln_seq')::text, 10, '0') AS ebeln,
        '1000'::varchar(4) AS bukrs,
        rv.lifnr,
        CURRENT_DATE - (random() * 365 * 3)::int AS bedat,
        'EUR'::varchar(5) AS waers
    FROM counts c
    CROSS JOIN generate_series(1, c.n_rest_pos) g(i)
    JOIN rest_vendors rv
      ON rv.idx = ((g.i - 1) % NULLIF((SELECT n_rest_vendors FROM counts), 0)) + 1
)

INSERT INTO bootstrap.ekko_clean (ebeln, bukrs, lifnr, bedat, waers)
SELECT * FROM top_pos
UNION ALL
SELECT * FROM rest_pos;
