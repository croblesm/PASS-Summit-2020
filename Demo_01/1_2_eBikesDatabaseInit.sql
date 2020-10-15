-- Initializing database
SET NOCOUNT ON;
GO
USE master
GO

-- Creating eBikes database
CREATE DATABASE eBikes;
GO

-- Creating Flyway login
CREATE LOGIN flyway WITH PASSWORD=N'_D3v3L0pM3nt_',
    DEFAULT_DATABASE=eBikes, CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;
GO

-- Granting server-level roles (security, linked servers database creation)
EXEC sp_addsrvrolemember 'flyway', 'securityadmin';
EXEC sp_addsrvrolemember 'flyway', 'setupadmin';
EXEC sp_addsrvrolemember 'flyway', 'dbcreator';
GO

-- Creating database user, granting db_owner permission
USE eBikes
GO

CREATE USER flyway FOR LOGIN flyway;
EXEC sp_addrolemember 'db_owner', 'flyway';
GO