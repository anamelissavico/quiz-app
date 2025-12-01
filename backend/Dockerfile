# --------------------------------------------------------------------------------
# Estágio 1: Build (Utiliza a imagem SDK para compilar a aplicação)
# --------------------------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copia o arquivo .csproj e restaura dependências (otimização de cache)
# Mude YourApp.csproj para o nome real do seu arquivo .csproj
# 🎯 AQUI: Substitua "YourApp.csproj" pelo nome do seu arquivo de projeto (ex: MeuProjeto.csproj)
COPY ["quizzAPI.csproj", ""]
RUN dotnet restore "quizzAPI.csproj"

# Copia o restante dos arquivos do projeto e compila
COPY . .
RUN dotnet publish "quizzAPI.csproj" -c Release -o /app/publish

# --------------------------------------------------------------------------------
# Estágio 2: Runtime (Imagem final de produção - Menor e mais segura)
# --------------------------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# A porta 80 é a porta padrão que o ASP.NET Core usa dentro do container
EXPOSE 80

# Copia os binários compilados do estágio 'build'
COPY --from=build /app/publish .

# Define o ponto de entrada para iniciar a aplicação (mude YourApp.dll)
# 🎯 AQUI: Substitua "YourApp.dll" pelo nome do seu arquivo DLL executável (ex: MeuProjeto.dll)
ENTRYPOINT ["dotnet", "quizzAPI.dll"]