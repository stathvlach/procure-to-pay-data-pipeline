-- =====================================================================
-- Project : Procure-to-Pay Data Platform
-- Layer   : bootstrap
-- Folder  : init
-- File    : 002_bootstrap_constraints.sql
--
-- Purpose :
--   Define structural constraints for bootstrap tables to ensure
--   deterministic data generation and basic structural integrity.
--
-- Description:
--   This script applies database constraints to selected bootstrap tables
--   after their creation. Constraints are intentionally minimal and are
--   designed to support reproducible synthetic data generation without
--   restricting controlled data corruption scenarios.
--
--   In particular:
--     - Primary key constraints are applied only to clean baseline tables,
--       ensuring uniqueness of business identifiers in valid datasets.
--     - Corrupted tables are intentionally left unconstrained (or rely on
--       surrogate identifiers if defined) to allow missing, duplicated, or
--       malformed business keys as part of corruption scenarios.
--
--   No foreign key constraints are defined in the bootstrap schema.
--   Referential consistency is deliberately deferred to downstream layers
--   (staging and operational).
--
-- Inputs :
--   Bootstrap tables created by 001_bootstrap_create_tables.sql
--
-- Outputs:
--   Structural constraints applied to bootstrap clean tables (PRIMARY KEYs).
--
-- Execution Context:
--   Executed during database initialization after bootstrap tables have been
--   created. Intended to be re-runnable in development environments.
--
-- Notes :
--   - Primary key constraints implicitly enforce NOT NULL on key columns
--     in PostgreSQL; this is acceptable for clean baseline datasets.
--   - Constraint definitions are separated from table creation to allow
--     flexible constraint strategies per layer.
--
-- Author : Stathis Vlachos
-- =====================================================================

ALTER TABLE bootstrap.ekko_clean
  ADD CONSTRAINT pk_ekko_clean PRIMARY KEY (ebeln);

ALTER TABLE bootstrap.ekpo_clean
  ADD CONSTRAINT pk_ekpo_clean PRIMARY KEY (ebeln, ebelp);

ALTER TABLE bootstrap.mkpf_clean
  ADD CONSTRAINT pk_mkpf_clean PRIMARY KEY (mblnr, mjahr);

ALTER TABLE bootstrap.mseg_clean
  ADD CONSTRAINT pk_mseg_clean PRIMARY KEY (mblnr, mjahr, zeile);

ALTER TABLE bootstrap.rbkp_clean
  ADD CONSTRAINT pk_rbkp_clean PRIMARY KEY (belnr, gjahr);

ALTER TABLE bootstrap.rseg_clean
  ADD CONSTRAINT pk_rseg_clean PRIMARY KEY (belnr, gjahr, buzei);
