-- ==============================================================================
-- 
-- Script name   :   V1.1__Create-ProductsRelated-Tables.sql
-- Description   :   SQL migration to create Categories, Brands and Products tables
-- Author        :   SQL Server tutorial
-- Modified      :   Carlos Robles
-- Email         :   crobles@dbamastery.com
-- Twitter       :   @dbamastery
-- Date          :   2020-09
--   
-- Notes         :   Original script taken from:
--					 http://www.sqlservertutorial.net/load-sample-database/
-- 
-- ==============================================================================

-- Create categories table
CREATE TABLE production.categories (
	category_id INT IDENTITY (1, 1) PRIMARY KEY,
	category_name VARCHAR (256) NOT NULL
);

-- Create categories brands table
CREATE TABLE production.brands (
	brand_id INT IDENTITY (1, 1) PRIMARY KEY,
	brand_name VARCHAR (256) NOT NULL
);

-- Create categories products table
CREATE TABLE production.products (
	product_id INT IDENTITY (1, 1) PRIMARY KEY,
	product_name VARCHAR (256) NOT NULL,
	brand_id INT NOT NULL,
	category_id INT NOT NULL,
	model_year SMALLINT NOT NULL,
	list_price DECIMAL (10, 2) NOT NULL,
	FOREIGN KEY (category_id) REFERENCES production.categories (category_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (brand_id) REFERENCES production.brands (brand_id) ON DELETE CASCADE ON UPDATE CASCADE
);