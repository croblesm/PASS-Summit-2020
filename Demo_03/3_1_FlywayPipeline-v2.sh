# Demo 03 - Application + Database migrations on CI/CD pipelines (Kubernetes) - v2.0
# 
#   1- Review repository structure
#   2- Check webapp rollout history - Kubernetes deployment
#   3- Create version 2.0 branch (local repository)
#   4- Exchange webapp versions
#   5- Add new migrations to SQL scripts folder
#   6- Review Flyway new migrations structure'
#   7- Review Flyway migrations - SQL files
#   8- Change pipeline CI options
#   9- Push changes to repository (v2.0)
#   10- Create pull request (master <- v2.0)
#   11- Monitor Azure pipeline
#   12- Check Flyway migration job status
#   13- Review Flyway schema history
#   14- Review changes in SQL Server GeoKids database
#   15- Check GeoKids website - New frontend (v2.0)
#   16- Repository cleanup and release tag
# -----------------------------------------------------------------------------
# Reference:
#   Flyway
#   https://flywaydb.org/documentation/
#   https://github.com/flyway/flyway-docker
#
#   GeoKids
#   https://github.com/geo-kids
#   https://dev.azure.com/GeoKids

# 0- Local variables | Demo path
# Variables
ConfigFile=./Demo_03/ConfigFile;
FlywayPassword='_D3v3L0pM3nt_';
SQLCMDPASSWORD='_SqLr0ck5_';
SQLCMDUSER='SA';
GeoKidsWeb=`kubectl get services geokids-service-web --output jsonpath='{.status.loadBalancer.ingress[0].ip}'`

# 1- Review repository structure
Demo_03
├── Database # Current database version (v1.0) in production 👀
├── Manifests # SQL Server, web app, flyway migration job
├── WebApp # Current webapp version (v1.0) in production 👀
├── v2-WebApp
│   ├── Images
│   │   └── Dockerfile  # Web app v2.0 image (Development) - New frontend design
│   ├── Models
│   ├── Views
│   ├── Controllers
│   ├── Properties
│   └── wwwroot
├── v2-SQLScripts # Database version v2.0 (Development) - New database schema 📝
│   ├── V2.1__Add-FlagColumn-CountriesTable.sql
│   ├── V2.2__Load-CountryFlags-Data.sql
│   └── V2.3__Create-ViewStructures.sql
└── azure-pipelines.yaml # Azure DevOps Pipeline 🤖

# 2- Check webapp rollout history - Kubernetes deployment
kubectl rollout history deployment geokids-web-deployment

# 3- Create version 2.0 branch (local repository)
git checkout -b v2.0
git branch -a

# 4- Exchange webapp versions
# Rename current WebApp folder to v1
mv ./WebApp ./v1-WebApp

# Rename v2 WebApp folder to current
mv ./v2-WebApp ./WebApp

# 5- Add new migrations to SQL scripts folder
cp ./v2-SQLScripts/V2.1__Add-FlagColumn-CountriesTable.sql ./Database/SQLScripts;
cp ./v2-SQLScripts/V2.2__Load-CountryFlags-Data.sql ./Database/SQLScripts;
cp ./v2-SQLScripts/V2.3__Create-ViewStructures.sql ./Database/SQLScripts;

# 6- Review Flyway new migrations structure
Flyway migration
├── Images
│   └── Dockerfile
└── SQLScripts
    ├── V1.1__Create-TableStructures.sql
    ├── V1.2__Create-TableConstraints.sql
    ├── V1.3__Load-TableData.sql
    ├── V2.1__Add-FlagColumn-CountriesTable.sql     --> New column! References to actual country flag 🏳️
    ├── V2.2__Load-CountryFlags-Data.sql            --> Country flag data 🇬🇹 🇺🇸
    └── V2.3__Create-ViewStructures.sql             --> New views! Applying database development best practices 👌

# 7- Review Flyway migrations - SQL files
# Database schema version 2.0
code ./Database/SQLScripts/V2.1__Add-FlagColumn-CountriesTable.sql;
code ./Database/SQLScripts/V2.2__Load-CountryFlags-Data.sql;
code ./Database/SQLScripts/V2.3__Create-ViewStructures.sql;

# 8- Change pipeline CI options
code ./"Pipeline-CI config-v2.png"
code ./"Pipeline-PR config-v2.png"

# 9- Push changes to repository (v2.0)
git add .
git commit -am "New application and database schema version (2.0)"
git push --set-upstream origin v2.0

# 10- Create pull request (master <- v2.0)
open https://github.com/geo-kids/geokids-app

# 11- Monitor Azure pipeline
open https://dev.azure.com/GeoKids/GeoKids%20-%20PASS%20Summit/

# 12- Check Flyway migration job status
# Getting all kubernetes jobs
kubectl get jobs

# Describing last migration job (Kubernetes job)
migration_job=`kubectl get jobs --sort-by=.metadata.creationTimestamp | tail -1 | awk '{print $1}'`
kubectl describe job $migration_job

# Checking Flyway migration logs (Kubernetes pod)
migration_pod=$(kubectl get pods --selector=job-name=$migration_job --output=jsonpath='{.items[*].metadata.name}')
echo $migration_pod
kubectl logs $migration_pod -f

# 13- Review Flyway schema history
# Limiting the number of characters by column does the trick 👌
sqlcmd -S 127.0.0.1,1402 -U SA -d GeoKids \
    -Q "SET NOCOUNT ON; \
    SELECT  
        CONVERT(VARCHAR(8),version) as version,
        CONVERT(VARCHAR(32),description) as description,
        CONVERT(VARCHAR(32),script) as script,
        installed_on
    FROM dbo.flyway_schema_history;"

# 14- Review changes in SQL Server GeoKids database
# Check database objects (Query)
sqlcmd -S 127.0.0.1,1402 -U SA -d GeoKids \
     -Q "SET NOCOUNT ON; \
        SELECT  
            CONVERT(VARCHAR(32),TABLE_SCHEMA) as TABLE_SCHEMA,
            CONVERT(VARCHAR(40),TABLE_NAME) as TABLE_NAME
        FROM INFORMATION_SCHEMA.TABLES;"

# 15- Check GeoKids website - New frontend (v2.0)
open http://$GeoKidsWeb:8083

# 16- Repository cleanup and release tag
# List all branches
git branch -a
git checkout master
git pull

# Delete local branch
git branch -d v2.0

# Delete remote branch
git push origin --delete v2.0

# Create release tag
https://github.com/geo-kids/geokids-app/tags
