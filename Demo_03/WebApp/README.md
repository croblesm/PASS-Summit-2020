# Geo Kids Web - .NET Core Version

Container that allows launching a website for the technical demo of the GeoKids game.

### Restore packages and Run

```
dotnet restore

dotnet run
```

### Build the container
```
docker build --force-rm -t geokids/geokids-web-net:1.0 .
```

### Run the container
```
docker run -p 8083:80
    \ -e DB_USER=<db_user>
    \ -e DB_PASS="<db_pass>"
    \ -e DB_HOST=<db_hostname>
    \ -e DB_PORT=<db_port> 
    \ -e DB_NAME=<db_name> 
    \ --name geokids-web-net -d geokids/geokids-web-net:1.0
```