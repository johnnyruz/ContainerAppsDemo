#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["FrontendWebMVC/FrontendWebMVC.csproj", "FrontendWebMVC/"]
RUN dotnet restore "FrontendWebMVC/FrontendWebMVC.csproj"
COPY . .
WORKDIR "/src/FrontendWebMVC"
RUN dotnet build "FrontendWebMVC.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "FrontendWebMVC.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "FrontendWebMVC.dll"]