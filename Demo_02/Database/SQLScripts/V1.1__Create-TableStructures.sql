-- ==============================================================================
-- 
-- Script name   :   V1.1__Create-TableStructures.sql
-- Description   :   SQL migration to create geokids database tables
--                   continents, regions, countries
-- Author        :   Carlos Robles
-- Email         :   crobles@dbamastery.com
-- Twitter       :   @dbamastery
-- Date          :   2020-09
--   
-- Notes         :   N/A
-- 
-- ==============================================================================

-- Create continents table
-- ==============================================================================
CREATE TABLE continents (
    continent_id INT NOT NULL IDENTITY (1, 1),
	continent VARCHAR(64) NULL
);

-- Create regions table
-- ==============================================================================
CREATE TABLE regions (
	region_id INT NOT NULL IDENTITY (1, 1),
	region VARCHAR(64) NULL,
    continent_id INT NOT NULL
);

 -- Create countries table
 -- ==============================================================================
CREATE TABLE countries (
	country_id CHAR(2) NOT NULL,
	country VARCHAR(64) NULL,
    un_m49 INT NOT NULL,
	region_id INT NOT NULL
);