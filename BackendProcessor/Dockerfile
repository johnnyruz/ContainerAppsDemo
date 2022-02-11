#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["BackendProcessor/BackendProcessor.csproj", "BackendProcessor/"]
RUN dotnet restore "BackendProcessor/BackendProcessor.csproj"
COPY . .
WORKDIR "/src/BackendProcessor"
RUN dotnet build "BackendProcessor.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "BackendProcessor.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "BackendProcessor.dll"]