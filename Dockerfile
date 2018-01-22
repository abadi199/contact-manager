FROM microsoft/aspnetcore-build:2.0 AS build-env
WORKDIR /app

# copy csproj and restore as distinct layers
COPY src/BackEnd/*.fsproj ./
RUN dotnet restore

# copy everything else and build
COPY src/BackEnd/ ./
RUN dotnet publish -c Release -o out

# build runtime image
FROM microsoft/aspnetcore:2.0
WORKDIR /app
COPY --from=build-env /app/out .
COPY --from=build-env /app/*.db .
ENTRYPOINT ["dotnet", "ContactManager.dll"]