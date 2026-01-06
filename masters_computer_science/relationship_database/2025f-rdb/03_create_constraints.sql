-- ============================================================================
-- SYNTHEA HEALTHCARE DATABASE - CONSTRAINTS
-- BSc Database Exam 2025
-- ============================================================================
-- This script adds foreign key constraints and indexes to the database.
--
-- IMPORTANT: Run scripts in this order:
--   1. 01_create_tables.sql  (creates database and tables)
--   2. 02_insert_data.sql    (inserts all data)
--   3. 03_create_constraints.sql (THIS FILE - adds constraints)
--
-- If you get FK constraint errors, re-run from step 1.
-- ============================================================================

USE synthea_exam;

-- ============================================================================
-- COLUMN SIZE FIXES (for existing databases)
-- ============================================================================
-- Data uses full state names like 'Massachusetts', not abbreviations
ALTER TABLE patients MODIFY COLUMN PAT_STATE VARCHAR(50);

-- ============================================================================
-- DROP EXISTING CONSTRAINTS (for re-runs)
-- ============================================================================
-- MySQL doesn't support "DROP FOREIGN KEY IF EXISTS", so we use a procedure

DELIMITER //

DROP PROCEDURE IF EXISTS drop_fk_if_exists//

CREATE PROCEDURE drop_fk_if_exists(IN tbl_name VARCHAR(64), IN fk_name VARCHAR(64))
BEGIN
    DECLARE fk_count INT;

    SELECT COUNT(*) INTO fk_count
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = tbl_name
      AND CONSTRAINT_NAME = fk_name
      AND CONSTRAINT_TYPE = 'FOREIGN KEY';

    IF fk_count > 0 THEN
        SET @sql = CONCAT('ALTER TABLE ', tbl_name, ' DROP FOREIGN KEY ', fk_name);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END//

DELIMITER ;

SET FOREIGN_KEY_CHECKS = 0;

-- Drop all existing foreign keys
CALL drop_fk_if_exists('providers', 'fk_prv_org');
CALL drop_fk_if_exists('encounters', 'fk_enc_pat');
CALL drop_fk_if_exists('encounters', 'fk_enc_org');
CALL drop_fk_if_exists('encounters', 'fk_enc_prv');
CALL drop_fk_if_exists('encounters', 'fk_enc_pay');
CALL drop_fk_if_exists('conditions', 'fk_con_pat');
CALL drop_fk_if_exists('conditions', 'fk_con_enc');
CALL drop_fk_if_exists('observations', 'fk_obs_pat');
CALL drop_fk_if_exists('observations', 'fk_obs_enc');
CALL drop_fk_if_exists('medications', 'fk_med_pat');
CALL drop_fk_if_exists('medications', 'fk_med_enc');
CALL drop_fk_if_exists('medications', 'fk_med_pay');
CALL drop_fk_if_exists('procedures', 'fk_prc_pat');
CALL drop_fk_if_exists('procedures', 'fk_prc_enc');
CALL drop_fk_if_exists('immunizations', 'fk_imm_pat');
CALL drop_fk_if_exists('immunizations', 'fk_imm_enc');
CALL drop_fk_if_exists('allergies', 'fk_alg_pat');
CALL drop_fk_if_exists('allergies', 'fk_alg_enc');
CALL drop_fk_if_exists('careplans', 'fk_cpl_pat');
CALL drop_fk_if_exists('careplans', 'fk_cpl_enc');
CALL drop_fk_if_exists('devices', 'fk_dev_pat');
CALL drop_fk_if_exists('devices', 'fk_dev_enc');

-- Clean up the procedure
DROP PROCEDURE IF EXISTS drop_fk_if_exists;

-- ============================================================================
-- ORPHAN RECORD CLEANUP
-- ============================================================================
-- Remove records that reference non-existent parent records.
-- This must run BEFORE adding foreign key constraints.
-- IMPORTANT: Delete from child tables FIRST, then parent tables.

-- Step 1: Delete from leaf tables (tables that reference both patients AND encounters)
-- Delete records where patient OR encounter doesn't exist
DELETE FROM conditions WHERE CON_PATID NOT IN (SELECT PAT_ID FROM patients)
    OR CON_ENCID NOT IN (SELECT ENC_ID FROM encounters);
DELETE FROM observations WHERE OBS_PATID NOT IN (SELECT PAT_ID FROM patients)
    OR (OBS_ENCID IS NOT NULL AND OBS_ENCID NOT IN (SELECT ENC_ID FROM encounters));
DELETE FROM medications WHERE MED_PATID NOT IN (SELECT PAT_ID FROM patients)
    OR MED_ENCID NOT IN (SELECT ENC_ID FROM encounters);
DELETE FROM procedures WHERE PRC_PATID NOT IN (SELECT PAT_ID FROM patients)
    OR PRC_ENCID NOT IN (SELECT ENC_ID FROM encounters);
DELETE FROM immunizations WHERE IMM_PATID NOT IN (SELECT PAT_ID FROM patients)
    OR IMM_ENCID NOT IN (SELECT ENC_ID FROM encounters);
DELETE FROM allergies WHERE ALG_PATID NOT IN (SELECT PAT_ID FROM patients)
    OR (ALG_ENCID IS NOT NULL AND ALG_ENCID NOT IN (SELECT ENC_ID FROM encounters));
DELETE FROM careplans WHERE CPL_PATID NOT IN (SELECT PAT_ID FROM patients)
    OR CPL_ENCID NOT IN (SELECT ENC_ID FROM encounters);
DELETE FROM devices WHERE DEV_PATID NOT IN (SELECT PAT_ID FROM patients)
    OR DEV_ENCID NOT IN (SELECT ENC_ID FROM encounters);

-- Step 2: Now safe to delete orphan encounters
DELETE FROM encounters WHERE ENC_PATID NOT IN (SELECT PAT_ID FROM patients);

-- Step 3: Clean up references to organizations (nullable FKs - use UPDATE)
UPDATE providers SET PRV_ORGID = NULL WHERE PRV_ORGID IS NOT NULL AND PRV_ORGID NOT IN (SELECT ORG_ID FROM organizations);
UPDATE encounters SET ENC_ORGID = NULL WHERE ENC_ORGID IS NOT NULL AND ENC_ORGID NOT IN (SELECT ORG_ID FROM organizations);

-- Step 4: Clean up references to providers
UPDATE encounters SET ENC_PRVID = NULL WHERE ENC_PRVID IS NOT NULL AND ENC_PRVID NOT IN (SELECT PRV_ID FROM providers);

-- Step 5: Clean up references to payers
UPDATE encounters SET ENC_PAYID = NULL WHERE ENC_PAYID IS NOT NULL AND ENC_PAYID NOT IN (SELECT PAY_ID FROM payers);
UPDATE medications SET MED_PAYID = NULL WHERE MED_PAYID IS NOT NULL AND MED_PAYID NOT IN (SELECT PAY_ID FROM payers);

-- Re-enable foreign key checks after cleanup
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- FOREIGN KEY CONSTRAINTS
-- ============================================================================

-- Providers -> Organizations
ALTER TABLE providers
    ADD CONSTRAINT fk_prv_org
    FOREIGN KEY (PRV_ORGID) REFERENCES organizations(ORG_ID)
    ON DELETE SET NULL ON UPDATE CASCADE;

-- Encounters -> Patients
ALTER TABLE encounters
    ADD CONSTRAINT fk_enc_pat
    FOREIGN KEY (ENC_PATID) REFERENCES patients(PAT_ID)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Encounters -> Organizations
ALTER TABLE encounters
    ADD CONSTRAINT fk_enc_org
    FOREIGN KEY (ENC_ORGID) REFERENCES organizations(ORG_ID)
    ON DELETE SET NULL ON UPDATE CASCADE;

-- Encounters -> Providers
ALTER TABLE encounters
    ADD CONSTRAINT fk_enc_prv
    FOREIGN KEY (ENC_PRVID) REFERENCES providers(PRV_ID)
    ON DELETE SET NULL ON UPDATE CASCADE;

-- Encounters -> Payers
ALTER TABLE encounters
    ADD CONSTRAINT fk_enc_pay
    FOREIGN KEY (ENC_PAYID) REFERENCES payers(PAY_ID)
    ON DELETE SET NULL ON UPDATE CASCADE;

-- Conditions -> Patients
ALTER TABLE conditions
    ADD CONSTRAINT fk_con_pat
    FOREIGN KEY (CON_PATID) REFERENCES patients(PAT_ID)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Conditions -> Encounters
ALTER TABLE conditions
    ADD CONSTRAINT fk_con_enc
    FOREIGN KEY (CON_ENCID) REFERENCES encounters(ENC_ID)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Observations -> Patients
ALTER TABLE observations
    ADD CONSTRAINT fk_obs_pat
    FOREIGN KEY (OBS_PATID) REFERENCES patients(PAT_ID)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Observations -> Encounters (nullable - some observations like QOLS don't have encounters)
ALTER TABLE observations
    ADD CONSTRAINT fk_obs_enc
    FOREIGN KEY (OBS_ENCID) REFERENCES encounters(ENC_ID)
    ON DELETE SET NULL ON UPDATE CASCADE;

-- Medications -> Patients
ALTER TABLE medications
    ADD CONSTRAINT fk_med_pat
    FOREIGN KEY (MED_PATID) REFERENCES patients(PAT_ID)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Medications -> Encounters
ALTER TABLE medications
    ADD CONSTRAINT fk_med_enc
    FOREIGN KEY (MED_ENCID) REFERENCES encounters(ENC_ID)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Medications -> Payers
ALTER TABLE medications
    ADD CONSTRAINT fk_med_pay
    FOREIGN KEY (MED_PAYID) REFERENCES payers(PAY_ID)
    ON DELETE SET NULL ON UPDATE CASCADE;

-- Procedures -> Patients
ALTER TABLE procedures
    ADD CONSTRAINT fk_prc_pat
    FOREIGN KEY (PRC_PATID) REFERENCES patients(PAT_ID)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Procedures -> Encounters
ALTER TABLE procedures
    ADD CONSTRAINT fk_prc_enc
    FOREIGN KEY (PRC_ENCID) REFERENCES encounters(ENC_ID)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Immunizations -> Patients
ALTER TABLE immunizations
    ADD CONSTRAINT fk_imm_pat
    FOREIGN KEY (IMM_PATID) REFERENCES patients(PAT_ID)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Immunizations -> Encounters
ALTER TABLE immunizations
    ADD CONSTRAINT fk_imm_enc
    FOREIGN KEY (IMM_ENCID) REFERENCES encounters(ENC_ID)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Allergies -> Patients
ALTER TABLE allergies
    ADD CONSTRAINT fk_alg_pat
    FOREIGN KEY (ALG_PATID) REFERENCES patients(PAT_ID)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Allergies -> Encounters (optional)
ALTER TABLE allergies
    ADD CONSTRAINT fk_alg_enc
    FOREIGN KEY (ALG_ENCID) REFERENCES encounters(ENC_ID)
    ON DELETE SET NULL ON UPDATE CASCADE;

-- Careplans -> Patients
ALTER TABLE careplans
    ADD CONSTRAINT fk_cpl_pat
    FOREIGN KEY (CPL_PATID) REFERENCES patients(PAT_ID)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Careplans -> Encounters
ALTER TABLE careplans
    ADD CONSTRAINT fk_cpl_enc
    FOREIGN KEY (CPL_ENCID) REFERENCES encounters(ENC_ID)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Devices -> Patients
ALTER TABLE devices
    ADD CONSTRAINT fk_dev_pat
    FOREIGN KEY (DEV_PATID) REFERENCES patients(PAT_ID)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Devices -> Encounters
ALTER TABLE devices
    ADD CONSTRAINT fk_dev_enc
    FOREIGN KEY (DEV_ENCID) REFERENCES encounters(ENC_ID)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================
-- Using procedure to handle older MySQL versions without IF NOT EXISTS support

DELIMITER //

DROP PROCEDURE IF EXISTS create_index_if_not_exists//

CREATE PROCEDURE create_index_if_not_exists(IN idx_name VARCHAR(64), IN tbl_name VARCHAR(64), IN col_name VARCHAR(64))
BEGIN
    DECLARE idx_count INT;

    SELECT COUNT(*) INTO idx_count
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = tbl_name
      AND INDEX_NAME = idx_name;

    IF idx_count = 0 THEN
        SET @sql = CONCAT('CREATE INDEX ', idx_name, ' ON ', tbl_name, '(', col_name, ')');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END//

DELIMITER ;

-- Patient indexes
CALL create_index_if_not_exists('idx_pat_last', 'patients', 'PAT_LAST');
CALL create_index_if_not_exists('idx_pat_city', 'patients', 'PAT_CITY');
CALL create_index_if_not_exists('idx_pat_state', 'patients', 'PAT_STATE');
CALL create_index_if_not_exists('idx_pat_gender', 'patients', 'PAT_GENDER');
CALL create_index_if_not_exists('idx_pat_race', 'patients', 'PAT_RACE');
CALL create_index_if_not_exists('idx_pat_brtdate', 'patients', 'PAT_BRTDATE');

-- Encounter indexes
CALL create_index_if_not_exists('idx_enc_patid', 'encounters', 'ENC_PATID');
CALL create_index_if_not_exists('idx_enc_orgid', 'encounters', 'ENC_ORGID');
CALL create_index_if_not_exists('idx_enc_prvid', 'encounters', 'ENC_PRVID');
CALL create_index_if_not_exists('idx_enc_class', 'encounters', 'ENC_CLASS');
CALL create_index_if_not_exists('idx_enc_start', 'encounters', 'ENC_START');

-- Condition indexes
CALL create_index_if_not_exists('idx_con_patid', 'conditions', 'CON_PATID');
CALL create_index_if_not_exists('idx_con_encid', 'conditions', 'CON_ENCID');
CALL create_index_if_not_exists('idx_con_code', 'conditions', 'CON_CODE');

-- Observation indexes
CALL create_index_if_not_exists('idx_obs_patid', 'observations', 'OBS_PATID');
CALL create_index_if_not_exists('idx_obs_encid', 'observations', 'OBS_ENCID');
CALL create_index_if_not_exists('idx_obs_code', 'observations', 'OBS_CODE');

-- Medication indexes
CALL create_index_if_not_exists('idx_med_patid', 'medications', 'MED_PATID');
CALL create_index_if_not_exists('idx_med_encid', 'medications', 'MED_ENCID');
CALL create_index_if_not_exists('idx_med_code', 'medications', 'MED_CODE');

-- Procedure indexes
CALL create_index_if_not_exists('idx_prc_patid', 'procedures', 'PRC_PATID');
CALL create_index_if_not_exists('idx_prc_encid', 'procedures', 'PRC_ENCID');
CALL create_index_if_not_exists('idx_prc_code', 'procedures', 'PRC_CODE');

-- Immunization indexes
CALL create_index_if_not_exists('idx_imm_patid', 'immunizations', 'IMM_PATID');
CALL create_index_if_not_exists('idx_imm_code', 'immunizations', 'IMM_CODE');

-- Allergy indexes
CALL create_index_if_not_exists('idx_alg_patid', 'allergies', 'ALG_PATID');

-- Careplan indexes
CALL create_index_if_not_exists('idx_cpl_patid', 'careplans', 'CPL_PATID');

-- Device indexes
CALL create_index_if_not_exists('idx_dev_patid', 'devices', 'DEV_PATID');

-- Provider indexes
CALL create_index_if_not_exists('idx_prv_orgid', 'providers', 'PRV_ORGID');
CALL create_index_if_not_exists('idx_prv_specity', 'providers', 'PRV_SPECITY');

-- Organization indexes
CALL create_index_if_not_exists('idx_org_city', 'organizations', 'ORG_CITY');
CALL create_index_if_not_exists('idx_org_state', 'organizations', 'ORG_STATE');

-- Clean up the procedure
DROP PROCEDURE IF EXISTS create_index_if_not_exists;

-- ============================================================================
-- End of constraints script
-- ============================================================================
