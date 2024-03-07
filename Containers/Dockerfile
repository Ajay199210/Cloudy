# See https://aka.ms/customizecontainer to learn how to customize your debug container
# and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["Src/API/ModernRecrut.Emplois.API/ModernRecrut.Emplois.API.csproj", "Src/API/ModernRecrut.Emplois.API/"]
RUN dotnet restore "Src/API/ModernRecrut.Emplois.API/ModernRecrut.Emplois.API.csproj"
COPY . .
WORKDIR "/src/Src/API/ModernRecrut.Emplois.API"
RUN dotnet build "ModernRecrut.Emplois.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ModernRecrut.Emplois.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ModernRecrut.Emplois.API.dll"]