-- ============================================================================
-- SYNTHEA HEALTHCARE DATABASE - TABLE CREATION
-- BSc Database Exam 2025
-- ============================================================================
-- This script creates the database schema for a healthcare records system
-- based on the Synthea synthetic patient generator dataset.
--
-- Column naming convention: XXX_YYYYYYYY
--   XXX = 3-letter table code
--   YYYYYYYY = field name (max 8 characters)
-- ============================================================================

DROP DATABASE IF EXISTS synthea_exam;
CREATE DATABASE synthea_exam CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE synthea_exam;

-- ============================================================================
-- ORGANIZATIONS TABLE (ORG)
-- Healthcare facilities: hospitals, clinics, etc.
-- ============================================================================
CREATE TABLE organizations (
    ORG_ID VARCHAR(36) PRIMARY KEY,
    ORG_NAME VARCHAR(255) NOT NULL,
    ORG_ADDRESS VARCHAR(255),
    ORG_CITY VARCHAR(100),
    ORG_STATE VARCHAR(10),
    ORG_ZIP VARCHAR(20),
    ORG_LAT DECIMAL(10, 6),
    ORG_LON DECIMAL(10, 6),
    ORG_PHONE VARCHAR(30),
    ORG_REVENUE DECIMAL(15, 2),
    ORG_UTILIZN INT
) ENGINE=InnoDB;

-- ============================================================================
-- PAYERS TABLE (PAY)
-- Insurance payer organizations
-- ============================================================================
CREATE TABLE payers (
    PAY_ID VARCHAR(36) PRIMARY KEY,
    PAY_NAME VARCHAR(255) NOT NULL,
    PAY_OWNRSHP VARCHAR(50),
    PAY_ADDRESS VARCHAR(255),
    PAY_CITY VARCHAR(100),
    PAY_STATE VARCHAR(10),
    PAY_ZIP VARCHAR(20),
    PAY_PHONE VARCHAR(20),
    PAY_AMTCOVR DECIMAL(15, 2),
    PAY_AMTUNCV DECIMAL(15, 2),
    PAY_REVENUE DECIMAL(15, 2),
    PAY_COVENC INT,
    PAY_UNCVENC INT,
    PAY_COVMED INT,
    PAY_UNCVMED INT,
    PAY_COVPRC INT,
    PAY_UNCVPRC INT,
    PAY_UNIQCST INT
) ENGINE=InnoDB;

-- ============================================================================
-- PROVIDERS TABLE (PRV)
-- Healthcare clinicians
-- ============================================================================
CREATE TABLE providers (
    PRV_ID VARCHAR(36) PRIMARY KEY,
    PRV_ORGID VARCHAR(36),
    PRV_NAME VARCHAR(255) NOT NULL,
    PRV_GENDER VARCHAR(1),
    PRV_SPECITY VARCHAR(100),
    PRV_ADDRESS VARCHAR(255),
    PRV_CITY VARCHAR(100),
    PRV_STATE VARCHAR(10),
    PRV_ZIP VARCHAR(20),
    PRV_LAT DECIMAL(10, 6),
    PRV_LON DECIMAL(10, 6),
    PRV_ENCNTRS INT DEFAULT 0,
    PRV_PRCDURS INT DEFAULT 0
) ENGINE=InnoDB;

-- ============================================================================
-- PATIENTS TABLE (PAT)
-- Patient demographic information
-- ============================================================================
CREATE TABLE patients (
    PAT_ID VARCHAR(36) PRIMARY KEY,
    PAT_BRTDATE DATE NOT NULL,
    PAT_DTHDATE DATE,
    PAT_SSN VARCHAR(11),
    PAT_DRIVERS VARCHAR(50),
    PAT_PASSPRT VARCHAR(50),
    PAT_PREFIX VARCHAR(10),
    PAT_FIRST VARCHAR(100) NOT NULL,
    PAT_MIDDLE VARCHAR(100),
    PAT_LAST VARCHAR(100) NOT NULL,
    PAT_SUFFIX VARCHAR(10),
    PAT_MAIDEN VARCHAR(100),
    PAT_MARITAL VARCHAR(1),
    PAT_RACE VARCHAR(50),
    PAT_ETHNCTY VARCHAR(50),
    PAT_GENDER VARCHAR(1) NOT NULL,
    PAT_BRTHPLC VARCHAR(255),
    PAT_ADDRESS VARCHAR(255),
    PAT_CITY VARCHAR(100),
    PAT_STATE VARCHAR(50),
    PAT_COUNTY VARCHAR(100),
    PAT_ZIP VARCHAR(20),
    PAT_LAT DECIMAL(10, 6),
    PAT_LON DECIMAL(10, 6),
    PAT_HLTHEXP DECIMAL(15, 2),
    PAT_HLTHCOV DECIMAL(15, 2),
    PAT_INCOME INT
) ENGINE=InnoDB;

-- ============================================================================
-- ENCOUNTERS TABLE (ENC)
-- Medical encounters/visits
-- ============================================================================
CREATE TABLE encounters (
    ENC_ID VARCHAR(36) PRIMARY KEY,
    ENC_START DATETIME NOT NULL,
    ENC_STOP DATETIME,
    ENC_PATID VARCHAR(36) NOT NULL,
    ENC_ORGID VARCHAR(36),
    ENC_PRVID VARCHAR(36),
    ENC_PAYID VARCHAR(36),
    ENC_CLASS VARCHAR(50) NOT NULL,
    ENC_CODE VARCHAR(20),
    ENC_DESCRPT VARCHAR(255),
    ENC_BASECST DECIMAL(12, 2),
    ENC_TOTLCST DECIMAL(12, 2),
    ENC_PAYCOVR DECIMAL(12, 2),
    ENC_RSNCODE VARCHAR(20),
    ENC_RSNDESC VARCHAR(255)
) ENGINE=InnoDB;

-- ============================================================================
-- CONDITIONS TABLE (CON)
-- Diagnoses and medical conditions
-- ============================================================================
CREATE TABLE conditions (
    CON_ID INT AUTO_INCREMENT PRIMARY KEY,
    CON_START DATE NOT NULL,
    CON_STOP DATE,
    CON_PATID VARCHAR(36) NOT NULL,
    CON_ENCID VARCHAR(36) NOT NULL,
    CON_SYSTEM VARCHAR(50) DEFAULT 'SNOMED-CT',
    CON_CODE VARCHAR(20) NOT NULL,
    CON_DESCRPT VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

-- ============================================================================
-- OBSERVATIONS TABLE (OBS)
-- Vital signs, lab results, clinical observations
-- ============================================================================
CREATE TABLE observations (
    OBS_ID INT AUTO_INCREMENT PRIMARY KEY,
    OBS_DATE DATETIME NOT NULL,
    OBS_PATID VARCHAR(36) NOT NULL,
    OBS_ENCID VARCHAR(36),
    OBS_CATEGRY VARCHAR(50),
    OBS_CODE VARCHAR(20) NOT NULL,
    OBS_DESCRPT VARCHAR(255) NOT NULL,
    OBS_VALUE VARCHAR(255),
    OBS_UNITS VARCHAR(50),
    OBS_TYPE VARCHAR(20)
) ENGINE=InnoDB;

-- ============================================================================
-- MEDICATIONS TABLE (MED)
-- Prescribed medications
-- ============================================================================
CREATE TABLE medications (
    MED_ID INT AUTO_INCREMENT PRIMARY KEY,
    MED_START DATETIME NOT NULL,
    MED_STOP DATETIME,
    MED_PATID VARCHAR(36) NOT NULL,
    MED_PAYID VARCHAR(36),
    MED_ENCID VARCHAR(36) NOT NULL,
    MED_CODE VARCHAR(20) NOT NULL,
    MED_DESCRPT VARCHAR(300) NOT NULL,
    MED_BASECST DECIMAL(10, 2),
    MED_PAYCOVR DECIMAL(10, 2),
    MED_DISPENS INT DEFAULT 1,
    MED_TOTLCST DECIMAL(10, 2),
    MED_RSNCODE VARCHAR(20),
    MED_RSNDESC VARCHAR(255)
) ENGINE=InnoDB;

-- ============================================================================
-- PROCEDURES TABLE (PRC)
-- Medical and surgical procedures
-- ============================================================================
CREATE TABLE procedures (
    PRC_ID INT AUTO_INCREMENT PRIMARY KEY,
    PRC_START DATETIME NOT NULL,
    PRC_STOP DATETIME,
    PRC_PATID VARCHAR(36) NOT NULL,
    PRC_ENCID VARCHAR(36) NOT NULL,
    PRC_SYSTEM VARCHAR(50) DEFAULT 'SNOMED-CT',
    PRC_CODE VARCHAR(20) NOT NULL,
    PRC_DESCRPT VARCHAR(255) NOT NULL,
    PRC_BASECST DECIMAL(10, 2),
    PRC_RSNCODE VARCHAR(20),
    PRC_RSNDESC VARCHAR(255)
) ENGINE=InnoDB;

-- ============================================================================
-- IMMUNIZATIONS TABLE (IMM)
-- Vaccination records
-- ============================================================================
CREATE TABLE immunizations (
    IMM_ID INT AUTO_INCREMENT PRIMARY KEY,
    IMM_DATE DATETIME NOT NULL,
    IMM_PATID VARCHAR(36) NOT NULL,
    IMM_ENCID VARCHAR(36) NOT NULL,
    IMM_CODE VARCHAR(20) NOT NULL,
    IMM_DESCRPT VARCHAR(255) NOT NULL,
    IMM_COST DECIMAL(10, 2)
) ENGINE=InnoDB;

-- ============================================================================
-- ALLERGIES TABLE (ALG)
-- Patient allergies and intolerances
-- ============================================================================
CREATE TABLE allergies (
    ALG_ID INT AUTO_INCREMENT PRIMARY KEY,
    ALG_START DATE NOT NULL,
    ALG_STOP DATE,
    ALG_PATID VARCHAR(36) NOT NULL,
    ALG_ENCID VARCHAR(36),
    ALG_CODE VARCHAR(20),
    ALG_SYSTEM VARCHAR(50),
    ALG_DESCRPT VARCHAR(255) NOT NULL,
    ALG_TYPE VARCHAR(20),
    ALG_CATEGRY VARCHAR(50),
    ALG_REACTN1 VARCHAR(20),
    ALG_RDESC1 VARCHAR(255),
    ALG_SEVRITY VARCHAR(20)
) ENGINE=InnoDB;

-- ============================================================================
-- CAREPLANS TABLE (CPL)
-- Care plans for managing conditions
-- ============================================================================
CREATE TABLE careplans (
    CPL_ID VARCHAR(36) PRIMARY KEY,
    CPL_START DATE NOT NULL,
    CPL_STOP DATE,
    CPL_PATID VARCHAR(36) NOT NULL,
    CPL_ENCID VARCHAR(36) NOT NULL,
    CPL_CODE VARCHAR(20) NOT NULL,
    CPL_DESCRPT VARCHAR(255) NOT NULL,
    CPL_RSNCODE VARCHAR(20),
    CPL_RSNDESC VARCHAR(255)
) ENGINE=InnoDB;

-- ============================================================================
-- DEVICES TABLE (DEV)
-- Medical devices (implants, prosthetics)
-- ============================================================================
CREATE TABLE devices (
    DEV_ID INT AUTO_INCREMENT PRIMARY KEY,
    DEV_START DATETIME NOT NULL,
    DEV_STOP DATETIME,
    DEV_PATID VARCHAR(36) NOT NULL,
    DEV_ENCID VARCHAR(36) NOT NULL,
    DEV_CODE VARCHAR(20) NOT NULL,
    DEV_DESCRPT VARCHAR(255) NOT NULL,
    DEV_UDI VARCHAR(100)
) ENGINE=InnoDB;

-- ============================================================================
-- End of table creation script
-- ============================================================================
