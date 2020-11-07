FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build

WORKDIR /app
EXPOSE 80
EXPOSE 443

# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
WORKDIR /app
COPY --from=build /app/out .

ENTRYPOINT ["dotnet", "geo-kids-web-net.dll"]

# Labels
LABEL org.label-schema.name="Geovani de Leon"
LABEL maintainer="erwingeo1021@gmail.com"
LABEL org.label-schema.name="geokids-web-net"
LABEL org.label-schema.description="Web App - .NET Core GeoKids application"
LABEL org.label-schema.url="https://github.com/geo-kids"
LABEL org.label-schema.schema-version="1.0"