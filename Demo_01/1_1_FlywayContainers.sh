# Demo 01 - Getting started with Flyway migrations using Docker
# 
#   1- Create SQL Server container
#   2- Initialize eBikes database on SQL container
#   3- Review Flyway migrations folder structure
#   4- Review Flyway related files
#   5- Flyway migrations with Docker containers (V1 - eBikes)
#   6- Check eBikes database objects
#   7- Flyway migrations using Docker containers (V2 - eBikes)
#   8- Check eBikes database schema changes
# -----------------------------------------------------------------------------
# Reference:
#   https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility
#   https://flywaydb.org/documentation/
#   https://hub.docker.com/r/flyway/flyway
#   http://www.sqlservertutorial.net/load-sample-database
#   https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility
#
# Flyway - JDBC connection string
# SQL Server:   jdbc:SQL Server://<host>:<port>;databaseName=<database>

# 0- Env variables | demo path
cd ~/Documents/Summit-2020/Demo_01;
SQLCMDPASSWORD='CmdL1n3_r0ck5';
ConfigFile=~/Documents/Summit-2020/Demo_01/ConfigFile;
SQLScripts=~/Documents/Summit-2020/Demo_01/SQLScripts;

# Environment Cleanup 
# docker rm -f eBikes;
# docker volume rm vlm_SQLData;
# sqlcmd -S localhost,1400 -U SA -h -1 -Q "DROP DATABASE eBikes; DROP LOGIN flyway;"
# mv ./SQLScripts/V2.1__Load-ProductsRelated-data.sql ./v2-SQLScripts/V2.1__Load-ProductsRelated-data.sql;
# mv ./SQLScripts/V2.2__Load-SalesRelated-data.sql ./v2-SQLScripts/V2.2__Load-SalesRelated-data.sql;
# mv ./SQLScripts/V2.3__Load-OrdersRelated-data.sql ./v2-SQLScripts/V2.3__Load-OrdersRelated-data.sql;

# 1- Create SQL Server container
docker container run \
    --name eBikes \
    --hostname eBikes \
    --env 'ACCEPT_EULA=Y' \
    --env 'MSSQL_SA_PASSWORD=CmdL1n3_r0ck5' \
    --volume vlm_SQLData:/var/opt/mssql \
    --publish 1400:1433 \
    --memory="2g" --memory-swap="4g" \
    --detach mcr.microsoft.com/mssql/server:2019-CU8-ubuntu-18.04

# 2- Initialize eBikes database on SQL container
# Check SQL Server instance name
# SQLCMDPASSWORD='CmdL1n3_r0ck5' --> environment variable to set a default password for the current session
sqlcmd -S localhost,1400 -U SA -h -1 -Q "SET NOCOUNT ON; SELECT @@SERVERNAME;"

# eBikes database init - SQL file
code ./1_2_eBikesDatabaseInit.sql

# Init database, grant access to Flyway login to eBikes SQL container + database
sqlcmd -S localhost,1400 -U SA -d master -e -i 1_2_eBikesDatabaseInit.sql

# List all databases on eBikes SQL container
sqlcmd -S localhost,1400 -U SA -h -1 -Q "SET NOCOUNT ON; SELECT name from sys.databases;"

# List all tables in eBikes database
# Formatting output using fixed column size
sqlcmd -S localhost,1400 -U SA -d eBikes \
     -Q "SET NOCOUNT ON; \
        SELECT  
            CONVERT(VARCHAR(32),TABLE_SCHEMA) as TABLE_SCHEMA,
            CONVERT(VARCHAR(32),TABLE_NAME) as TABLE_NAME
        FROM INFORMATION_SCHEMA.TABLES;"

# 3- Review Flyway migrations folder structure
Demo_01
├── ConfigFile
│   └── flyway.conf
└── SQLScripts
    ├── V1.1__Create-ProductionRelated-Tables.sql
    ├── V1.2__Create-SalesRelated-Tables.sql
    └── V1.3__Create-OrdersRelated-Tables.sql

# 4- Review Flyway related files
# Flyway config file
code ./ConfigFile/flyway.conf

# Migrations (SQL scripts)
code ./SQLScripts/V1.1__Create-ProductionRelated-Tables.sql;
code ./SQLScripts/V1.2__Create-SalesRelated-Tables.sql;
code ./SQLScripts/V1.3__Create-OrdersRelated-Tables.sql;

# 5- Flyway migrations with Docker containers (V1 - eBikes)
# Flyway application structure
flyway
├── lib
├── licenses
├── conf
│   └── flyway.conf         --> Configuration file (ConfigFile volume)
├── drivers                 --> JDBC drivers
├── flyway                  --> macOS/Linux executable
├── jars                    --> Java-based migrations (as jars)
└── sql                     --> SQL-based migrations (SQLScripts volume)
    └── V1__Migration.sql   --> V1-Migration sample file

# Flyway container volumes
Volume              Usage
---------------     ---------------------------------------------------------------------
/flyway/conf 	    Directory containing a flyway.conf configuration file
/flyway/sql 	    The SQL files that you want Flyway to use (for SQL-based migrations)
/flyway/drivers     Directory containing the JDBC driver for your database
/flyway/jars 	    The jars files that you want Flyway to use (for Java-based migrations

# ConfigFile & SQLScripts environment variables for actual path
ConfigFile=~/Documents/Summit-2020/Demo_01/ConfigFile;
SQLScripts=~/Documents/Summit-2020/Demo_01/SQLScripts;

# Initializing flyway
# --network host: host network mode to use localhost bridge network in config file
docker container run --rm \
    --volume $ConfigFile:/flyway/conf \
    --volume $SQLScripts:/flyway/sql \
    --network host \
    flyway/flyway info

# Perform V1 migration
docker container run --rm \
    --volume $ConfigFile:/flyway/conf \
    --volume $SQLScripts:/flyway/sql \
    --network host \
    flyway/flyway migrate

# Check status (Flyway)
docker container run --rm \
    --volume $ConfigFile:/flyway/conf \
    --volume $SQLScripts:/flyway/sql \
    --network host \
    flyway/flyway info

# Check status (Query)
sqlcmd -S localhost,1400 -U SA -d eBikes \
    -Q "SET NOCOUNT ON; \
    SELECT  
        CONVERT(VARCHAR(8),version) as version,
        CONVERT(VARCHAR(32),description) as description,
        CONVERT(VARCHAR(32),script) as script,
        installed_on
    FROM eBikes.dbo.flyway_schema_history;"

# --------------------------------------
# Azure Data Studio step
# --------------------------------------
# 6- Check eBikes database objects
# Check database objects (Query)
sqlcmd -S localhost,1400 -U SA -d eBikes \
     -Q "SET NOCOUNT ON; \
        SELECT  
            CONVERT(VARCHAR(32),TABLE_SCHEMA) as TABLE_SCHEMA,
            CONVERT(VARCHAR(32),TABLE_NAME) as TABLE_NAME
        FROM INFORMATION_SCHEMA.TABLES;"

# 7- Flyway migrations using Docker containers (V2 - eBikes)
# Data load scripts
code ./v2-SQLScripts/V2.1__Load-ProductsRelated-data.sql;
code ./v2-SQLScripts/V2.2__Load-SalesRelated-data.sql;
code ./v2-SQLScripts/V2.3__Load-OrdersRelated-data.sql;

# Copy (move) scripts to sql migrations folder
mv ./v2-SQLScripts/V2.1__Load-ProductsRelated-data.sql ./SQLScripts/V2.1__Load-ProductsRelated-data.sql;
mv ./v2-SQLScripts/V2.2__Load-SalesRelated-data.sql ./SQLScripts/V2.2__Load-SalesRelated-data.sql;
mv ./v2-SQLScripts/V2.3__Load-OrdersRelated-data.sql ./SQLScripts/V2.3__Load-OrdersRelated-data.sql;

# Updated folder structure
Demo_01
├── ConfigFile
│   └── flyway.conf
└── SQLScripts
    ├── V1.1__Create-CustomerRelated-Tables.sql
    ├── V1.2__Create-ProductRelated-Tables.sql
    ├── V1.3__Create-RegionsRelated-Tables.sql
    ├── V2.1__Load-CustomerRelated-data.sql --> Now visible to Flyway
    ├── V2.2__Load-ProductsRelated-data.sql --> Now visible to Flyway
    └── V2.3__Load-RegionsRelated-data.sql  --> Now visible to Flyway

# Check status (Flyway)
docker container run --rm \
    --volume $ConfigFile:/flyway/conf \
    --volume $SQLScripts:/flyway/sql \
    --network host \
    flyway/flyway info

# Perform V2 migration, checking status
docker container run --rm \
    --volume $ConfigFile:/flyway/conf \
    --volume $SQLScripts:/flyway/sql \
    --network host \
    flyway/flyway migrate info

# --------------------------------------
# Azure Data Studio step
# --------------------------------------
# 8- Check eBikes database schema changes
# Check status (Query)
sqlcmd -S localhost,1400 -U SA -d eBikes \
     -Q "SET NOCOUNT ON; \
        SELECT  
            CONVERT(VARCHAR(32),TABLE_SCHEMA) as TABLE_SCHEMA,
            CONVERT(VARCHAR(32),TABLE_NAME) as TABLE_NAME
        FROM INFORMATION_SCHEMA.TABLES;"