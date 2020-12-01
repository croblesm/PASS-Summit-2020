# Demo 02 - Application + Database migrations on CI/CD pipelines (Kubernetes) - v1.0
# 
#   1- Repository structure
#   2- Kubernetes architecture
#   3- Connect and show SQL Server GeoKids empty shell database
#   4- Review Flyway migration image
#   5- Review Flyway migrations - SQL files (v1.0)
#   6- Review Dockerfiles
#   7- Review Kubernetes manifests
#   8- Review Azure pipeline
#   9- Push changes to repository
#   10- Monitor Azure pipeline
#   11- Check Flyway migration job status
#   12- Review Flyway schema history
#   13- Review changes in SQL Server GeoKids database
#   14- Check GeoKids website
#   15- Create Kubernetes and GitHub release tag
#   16- Check pipeline CI options
# -----------------------------------------------------------------------------
# Reference:
#   Flyway
#   https://flywaydb.org/documentation/
#   https://github.com/flyway/flyway-docker
#
#   GeoKids - Repository
#   https://github.com/geo-kids
#   https://dev.azure.com/GeoKids

# 0- Local variables | Demo path
# Variables
ConfigFile=./Demo_02/ConfigFile;
FlywayPassword='_D3v3L0pM3nt_';
SQLCMDPASSWORD='_SqLr0ck5_';
SQLCMDUSER='SA';
GeoKidsWeb=`kubectl get services geokids-service-web --output jsonpath='{.status.loadBalancer.ingress[0].ip}'`

# 1- Repository structure (Integrated solution)
#   GeoKids
#   Description:    Learn geography by playing
#   Architecture:   .NET Core + SQL Server app
#
#   Repository:
#   https://github.com/geo-kids
#   https://dev.azure.com/GeoKids

Demo_02
├── Database
│   ├── Images
│   │   └── Dockerfile # Flyway migrations image
│   └── SQLScripts
│       ├── V1.1__Create-TableStructures.sql
│       ├── V1.2__Create-TableConstraints.sql
│       └── V1.3__Load-TableData.sql
├── Manifests
│   ├── dep-geokids-db.yaml # Web app deployment
│   ├── dep-geokids-web.yaml # SQL Server deployment
│   └── job-geokids-migration.yaml # Flyway migrations job
├── WebApp
│   ├── Images
│   │   └── Dockerfile # Web app image
│   ├── Models
│   ├── Views
│   ├── Controllers
│   ├── Properties
│   └── wwwroot
└── azure-pipelines.yaml # Azure DevOps Pipeline 🤖

# 2- Kubernetes architecture
# Kubernetes cluster (1.18 version)
kubectl config get-contexts
kubectl config use-context geokids
kubectl get nodes

# Kubernetes deployments
kubectl get deployments
kubectl describe deployment/geokids-db-deployment
# YAML file
code ./Manifests/dep-geokids-db.yaml

# Kubernetes pods
# Get the list of pods including node name (SQL Server runs on 01 node)
kubectl get pod -o=custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName

# Kubernetes services
kubectl get services
# NodePort for SQL Server --> No inbound connectivity outside Kubernetes cluster, port 1401
# LoadBalance for WebApp --> Inbound connectivity from internet, port 8083

# 3- Connect and show SQL Server GeoKids empty shell database
# mssql-tools-alpine: Minimalistic SQLCMD container image (~17 MBs) 👀 👍
# It provides portability and agility to run queries using a SQLCMD container on the fly.
# https://github.com/dbamaster/mssql-tools-alpine 

# Using SQLCMD container as bastion - Kubernetes pod
########################################################################################################
# sqlcmd-pod lives to fulfill its destiny: Execute queries and then, die 😅
# SQLCMD is your friend 😎 !! 

# Get all databases
# Kubernetes pod "sqlcmd-pod" created on node 01, if true all resources will be deleted
# ProTip: Simple and clean list, just removing column header 👀 
kubectl run sqlcmd-pod -i --tty --rm --restart=Never \
    --overrides='{"spec": { "nodeSelector": {"kubernetes.io/hostname": "aks-nodepool1-35295523-0"}}}' \
    --image=crobles10/mssql-tools-alpine:1.0 \
    -- sqlcmd -S geokids-service-db,1401 -U flyway -P $FlywayPassword -d master -h -1 \
     -Q "SET NOCOUNT ON; SELECT name from sys.databases;"

# Get all tables on GeoKids database - Formatted output
# Kubernetes pod "sqlcmd-pod" created on node 01, if true all resources will be deleted
# ProTip: Limiting the number of characters by column produces a clean output format 👌
kubectl run sqlcmd-pod -i --tty --rm --restart=Never \
    --overrides='{"spec": { "nodeSelector": {"kubernetes.io/hostname": "aks-nodepool1-35295523-0"}}}' \
    --image=crobles10/mssql-tools-alpine:1.0 \
    -- sqlcmd -S geokids-service-db,1401 -U flyway -P $FlywayPassword -d GeoKids \
     -Q "SET NOCOUNT ON; \
        SELECT  
            CONVERT(VARCHAR(32),TABLE_SCHEMA) as TABLE_SCHEMA,
            CONVERT(VARCHAR(32),TABLE_NAME) as TABLE_NAME
        FROM INFORMATION_SCHEMA.TABLES;"

# Using SQLCMD from local machine - Kubernetes port forwarding
########################################################################################################
# Getting SQL Server instance pod name
# Get cluster pod with "geokids-db" label, simple and clean list removing headers
sql_pod=`kubectl get pods -l app=geokids-db --no-headers -o custom-columns=":metadata.name"`

# Local machine port 1402 mapped to 1433 of Kubernetes SQL Server pod
kubectl port-forward pod/$sql_pod 1402:1433

# SA user and password as environment variable
# The SQLCMDPASSWORD environment variable lets you set a default password for the current session.
# The SQLCMDUSER environment variable lets you set a default user for the current session.
SQLCMDPASSWORD='_SqLr0ck5_';
SQLCMDUSER='sa';

# Get list of valid logins with access to SQL Server - Formatted output
# ProTip: Limiting the number of characters by column produces a clean output format 👌
sqlcmd -S 127.0.0.1,1402 -d master \
    -Q "SET NOCOUNT ON; \
    SELECT 
        CONVERT(VARCHAR(32),name) as login,
        CONVERT(VARCHAR(32),type_desc) as login_type,
        case when is_disabled = 1 then 'disabled' else 'enabled' end as status
    FROM sys.server_principals
    WHERE type not in ('G', 'R')
    AND name not like '##%'
    ORDER BY name;"

# 4- Review Flyway migration image
Flyway migration
├── Images
│   └── Dockerfile
└── SQLScripts
    ├── V1.1__Create-TableStructures.sql
    ├── V1.2__Create-TableConstraints.sql
    └── V1.3__Load-TableData.sql

# 5- Review Flyway migrations - SQL files
# Database Version: 1.0
########################################################################################################

# SQL Scripts
# Continents, regions and countries
code ./Database/SQLScripts/V1.1__Create-TableStructures.sql;
code ./Database/SQLScripts/V1.2__Create-TableConstraints.sql;
code ./Database/SQLScripts/V1.3__Load-TableData.sql;

# Flyway - Kubernetes API objects
# Flyway config file (ConfigMap) 📄
kubectl get configmaps/geokids-flyway-config
kubectl describe configmaps/geokids-flyway-config

# Flyway password (Secret) 🔐
kubectl get secrets/geokids-flyway-password
kubectl describe secrets/geokids-flyway-password
kubectl get secrets/geokids-flyway-password -o json

# JSON format
{
    "apiVersion": "v1",
    "data": {
        "flyway.password": "X0QzdjNMMHBNM250Xw==" 🧐 # This is the password hash, not actual password 😇
    },
    "kind": "Secret",
    "metadata": {
        "managedFields": [
        ],
        "name": "geokidsdb-flyway-password",
        "namespace": "default",
        "resourceVersion": "2736586",
        "selfLink": "/api/v1/namespaces/default/secrets/geokidsdb-flyway-password",
        "uid": "90d2eb2d-e54b-47a4-a1c2-85046994d3da"
    },
    "type": "Opaque"
}

# 6- Review Dockerfiles
# Flyway migrations
code ./Database/Images/Dockerfile

# Web app
code ./WebApp/Images/Dockerfile

# 7- Review Kubernetes manifests
Manifests 
├── dep-geokids-db.yaml
├── dep-geokids-web.yaml
└── job-geokids-migration.yaml

# YAML files
code ./Manifests/dep-geokids-db.yaml;
code ./Manifests/dep-geokids-web.yaml;
code ./Manifests/job-geokids-migration.yaml;

# 8- Review Azure pipeline
code azure-pipelines.yml

# 9- Push changes to repository
git add .
git commit -m "Base version (1.0) of GeoKids database and webapp"
git push

# 10- Monitor Azure pipeline
open https://dev.azure.com/GeoKids/GeoKids%20-%20PASS%20Summit/

# 11- Check Flyway migration job status
# Getting all kubernetes jobs
kubectl get jobs

# Describing last migration job (Kubernetes job)
migration_job=`kubectl get jobs --sort-by=.metadata.creationTimestamp | tail -1 | awk '{print $1}'`
kubectl describe job $migration_job

# Checking Flyway migration logs (Kubernetes pod)
migration_pod=$(kubectl get pods --selector=job-name=$migration_job --output=jsonpath='{.items[*].metadata.name}')
echo $migration_pod
kubectl logs $migration_pod -f

# 12- Review Flyway schema history
# Get Flyway migrations history from database table
# ProTip: Limiting the number of characters by column produces a clean output format 👌
sqlcmd -S 127.0.0.1,1402 -d GeoKids \
    -Q "SET NOCOUNT ON; \
    SELECT  
        CONVERT(VARCHAR(8),version) as version,
        CONVERT(VARCHAR(32),description) as description,
        CONVERT(VARCHAR(32),script) as script,
        installed_on
    FROM dbo.flyway_schema_history;"

# 13- Review changes in SQL Server GeoKids database
# Get all tables on GeoKids database - Formatted output
# ProTip: Limiting the number of characters by column produces a clean output format 👌
sqlcmd -S 127.0.0.1,1402 -d GeoKids \
     -Q "SET NOCOUNT ON; \
        SELECT  
            CONVERT(VARCHAR(32),TABLE_SCHEMA) as TABLE_SCHEMA,
            CONVERT(VARCHAR(32),TABLE_NAME) as TABLE_NAME
        FROM INFORMATION_SCHEMA.TABLES;"

# 14- Check GeoKids website
open http://$GeoKidsWeb:8083

# 15- Create Kubernetes and GitHub release tag
# Kubernetes annotation
kubectl annotate deployments.apps geokids-web-deployment \
    kubernetes.io/change-cause="GeoKids WebApp version 1.0" --record=false  --overwrite=true

# GitHub annotation
https://github.com/geo-kids/geokids-app/tags

# 16- Check pipeline CI options
# Pipelines --> Select pipeline --> Edit --> Triggers
code ./"Pipeline-CI config-v1.png"
