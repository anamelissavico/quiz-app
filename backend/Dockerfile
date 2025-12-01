# --------------------------------------------------------------------------------
# Estágio 1: Build (AGORA USANDO SDK 9.0 PREVIEW)
# --------------------------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copia o arquivo .csproj (mantendo a cópia local, já que Root Directory é 'backend')
COPY ["quizzAPI.csproj", ""] 
RUN dotnet restore "quizzAPI.csproj"

# Copia o restante dos arquivos do projeto e compila
COPY . .
RUN dotnet publish "quizzAPI.csproj" -c Release -o /app/publish

# --------------------------------------------------------------------------------
# Estágio 2: Runtime (AGORA USANDO ASPNET 9.0 PREVIEW)
# --------------------------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 80

# Copia os binários compilados do estágio 'build'
COPY --from=build /app/publish .

# Define o ponto de entrada para iniciar a aplicação
ENTRYPOINT ["dotnet", "quizzAPI.dll"]