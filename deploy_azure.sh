#!/bin/bash

# --- Variáveis de Configuração ---
RANDOM_SUFFIX=$RANDOM
RESOURCE_GROUP="rg-displaycsv-azure-foods"
LOCATION="canadacentral"
APP_SERVICE_PLAN="asp-displaycsv-azure-foods"
WEBAPP_NAME="webapp-displaycsv-azure-foods"
SQL_SERVER_NAME="sql-server-displaycsv-azure-foods"
SQL_DATABASE_NAME="sqldb-azure-foods"
SQL_ADMIN_USER="azureadmin"
SQL_ADMIN_PASSWORD="Password@123456"
APP_INSIGHTS_NAME="appi-displaycsv-azure-foods"
GITHUB_REPO_URL="https://github.com/RafaellSouzaPinto/displaycsv.git"

# --- Passo 1: Criação do Grupo de Recursos ---
echo "Criando Grupo de Recursos: $RESOURCE_GROUP..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# --- Passo 2: Criação do Plano de Serviço do Aplicativo ---
echo "Criando Plano de Serviço do Aplicativo: $APP_SERVICE_PLAN..."
az appservice plan create --name $APP_SERVICE_PLAN --resource-group $RESOURCE_GROUP --sku B1 --is-linux

# --- Passo 3: Criação do WebApp ---
echo "Criando WebApp: $WEBAPP_NAME..."
az webapp create --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP --plan $APP_SERVICE_PLAN --runtime "PYTHON:3.12"

# --- Passo 4: Criação do Servidor e Banco de Dados SQL do Azure ---
echo "Criando Servidor SQL: $SQL_SERVER_NAME..."
az sql server create --name $SQL_SERVER_NAME --resource-group $RESOURCE_GROUP --location $LOCATION --admin-user $SQL_ADMIN_USER --admin-password $SQL_ADMIN_PASSWORD

echo "Criando regra de firewall para liberar todas as portas da aplicação"
az sql server firewall-rule create --resource-group $RESOURCE_GROUP --server $SQL_SERVER_NAME --name AllowAzureServices --start-ip-address 0.0.0.0 --end-ip-address 255.255.255.255

echo "Criando Banco de Dados SQL: $SQL_DATABASE_NAME..."
az sql db create --name $SQL_DATABASE_NAME --resource-group $RESOURCE_GROUP --server $SQL_SERVER_NAME --service-objective S0

# --- Passo 5: Criação e Conexão do Application Insights ---
echo "Criando Application Insights: $APP_INSIGHTS_NAME..."
az monitor app-insights component create --app $APP_INSIGHTS_NAME --location $LOCATION --resource-group $RESOURCE_GROUP

echo "Conectando Application Insights ao WebApp..."
# Pega a Connection String do Application Insights que acabamos de criar.
APPINSIGHTS_CONNECTION_STRING=$(az monitor app-insights component show --app $APP_INSIGHTS_NAME --resource-group $RESOURCE_GROUP --query connectionString --output tsv)

# Define a Connection String nas configurações do WebApp para ativar o monitoramento.
az webapp config appsettings set --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP --settings APPLICATIONINSIGHTS_CONNECTION_STRING=$APPINSIGHTS_CONNECTION_STRING

# --- Passo 6: Configuração do Deploy a partir do GitHub ---
echo "Configurando o deploy contínuo a partir do GitHub..."
az webapp deployment source config --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP --repo-url $GITHUB_REPO_URL --branch main --manual-integration

# --- Finalização ---
WEBAPP_URL="http://$WEBAPP_NAME.azurewebsites.net"
echo "--------------------------------------------------------"
echo "Script concluído!"
echo "Grupo de Recursos: $RESOURCE_GROUP"
echo "URL do WebApp: $WEBAPP_URL"
echo "Servidor SQL: $SQL_SERVER_NAME"
echo "Para ver os logs do deploy, use o comando:"
echo "az webapp log tail --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP"
echo "--------------------------------------------------------"