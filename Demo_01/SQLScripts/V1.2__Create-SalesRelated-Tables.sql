-- ==============================================================================
-- 
-- Script name   :   V1.2__Create-SalesRelated-Tables.sql
-- Description   :   SQL migration to create Customers, Stores, Staff tables
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

-- Create customers table
CREATE TABLE sales.customers (
	customer_id INT IDENTITY (1, 1) PRIMARY KEY,
	first_name VARCHAR (256) NOT NULL,
	last_name VARCHAR (256) NOT NULL,
	phone VARCHAR (32),
	email VARCHAR (256) NOT NULL,
	street VARCHAR (256),
	city VARCHAR (128),
	state VARCHAR (16),
	zip_code VARCHAR (8)
);

-- Create stores table
CREATE TABLE sales.stores (
	store_id INT IDENTITY (1, 1) PRIMARY KEY,
	store_name VARCHAR (256) NOT NULL,
	phone VARCHAR (32),
	email VARCHAR (256),
	street VARCHAR (256),
	city VARCHAR (128),
	state VARCHAR (16),
	zip_code VARCHAR (8)
);

-- Create staffs table
CREATE TABLE sales.staffs (
	staff_id INT IDENTITY (1, 1) PRIMARY KEY,
	first_name VARCHAR (64) NOT NULL,
	last_name VARCHAR (64) NOT NULL,
	email VARCHAR (256) NOT NULL UNIQUE,
	phone VARCHAR (32),
	active tinyint NOT NULL,
	store_id INT NOT NULL,
	manager_id INT,
	FOREIGN KEY (store_id) REFERENCES sales.stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (manager_id) REFERENCES sales.staffs (staff_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);