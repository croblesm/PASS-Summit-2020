-- ==============================================================================
-- 
-- Script name   :   V1.2__Create-TableConstraints.sql
-- Description   :   SQL migration to create geokids database table contraints
--                   continents, regions, countries
-- Author        :   Carlos Robles
-- Email         :   crobles@dbamastery.com
-- Twitter       :   @dbamastery
-- Date          :   2020-09
--   
-- Notes         :   N/A
-- 
-- ==============================================================================

-- Create continent table constraints
-- ==============================================================================
-- Primary key
ALTER TABLE continents ADD CONSTRAINT pk_continents
    PRIMARY KEY CLUSTERED (continent_id);

-- Create regions table constraints
-- ==============================================================================
-- Primary key
ALTER TABLE regions ADD CONSTRAINT pk_regions
    PRIMARY KEY CLUSTERED (region_id);

-- Foreing key
ALTER TABLE regions ADD CONSTRAINT fk_regions_continents
    FOREIGN KEY (continent_id) REFERENCES continents (continent_id);

-- Create countries table constraints
-- ==============================================================================
-- Primary key
ALTER TABLE countries ADD CONSTRAINT pk_countries
    PRIMARY KEY CLUSTERED (country_id);

-- Foreing key
ALTER TABLE countries ADD CONSTRAINT fk_countries_regions
    FOREIGN KEY (region_id) REFERENCES regions (region_id);