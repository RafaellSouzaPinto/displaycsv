# Projeto DisplayCSV: Visualizador de Arquivos CSV com Deploy na Azure

Este é um projeto de uma aplicação web desenvolvida com Flask que permite aos usuários fazer o upload de um arquivo CSV e visualizar seu conteúdo em uma tabela HTML. O grande diferencial do projeto é o seu script de automação (`deploy_azure.sh`), que provisiona uma infraestrutura completa na Microsoft Azure e implanta a aplicação de forma automatizada.

## 📋 Índice

- [Funcionalidades](#-funcionalidades)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Tecnologias Utilizadas](#-tecnologias-utilizadas)
- [Pré-requisitos](#️-pré-requisitos)
- [Como Executar Localmente](#-como-executar-localmente)
- [Automação de Deploy na Azure](#️-automação-de-deploy-na-azure-com-deploy_azuresh)
- [Como Usar a Aplicação](#-como-usar-a-aplicação)

## ✨ Funcionalidades

- **Upload de Arquivos**: Interface simples para selecionar e enviar arquivos no formato `.csv`.
- **Visualização de Dados**: Exibição dos dados do arquivo CSV em uma tabela HTML formatada.
- **Tratamento de Codificação**: A aplicação tenta ler os arquivos com diferentes codificações (UTF-8, latin1, ISO-8859-1) para maximizar a compatibilidade.
- **Deploy Automatizado**: Um script shell (`.sh`) para provisionar toda a infraestrutura necessária e implantar a aplicação na Azure com um único comando.

## 📂 Estrutura do Projeto

```
/
├── templates/
│   ├── index.html       # Página inicial com o formulário de upload
│   └── display.html     # Página que exibe a tabela de dados
├── app.py               # Lógica principal da aplicação Flask
├── deploy_azure.sh      # Script de automação para deploy na Azure
├── requirements.txt     # Lista de dependências Python
└── README.md            # Este arquivo
```

## 🚀 Tecnologias Utilizadas

- **Backend**: Python 3.12, Flask, Pandas
- **Frontend**: HTML, CSS
- **Cloud & DevOps**: Microsoft Azure, Azure CLI, Bash Script, Git/GitHub

## ✔️ Pré-requisitos

### Para Execução Local:
- Python 3.10+
- pip

### Para o Deploy na Azure:
- Uma conta ativa na Microsoft Azure
- Azure CLI instalado e configurado em sua máquina

## 💻 Como Executar Localmente

1. Clone o repositório e navegue até a pasta:

```bash
git clone https://github.com/RafaellSouzaPinto/displaycsv.git
cd displaycsv
```

2. Crie e ative um ambiente virtual:

```bash
# Windows
python -m venv venv
.\venv\Scripts\activate

# macOS/Linux
python3 -m venv venv
source venv/bin/activate
```

3. Instale as dependências:

```bash
pip install -r requirements.txt
```

4. Execute a aplicação:

```bash
flask run
```

5. Acesse `http://127.0.0.1:5000` no seu navegador.

## ☁️ Automação de Deploy na Azure com deploy_azure.sh

O coração da automação deste projeto é o script `deploy_azure.sh`. Ele utiliza a Azure CLI (`az`) para criar e configurar todos os recursos necessários para hospedar a aplicação web na nuvem de forma reprodutível e rápida.

### Como Executar o Script

1. Faça login na sua conta Azure:

```bash
az login
```

2. Dê permissão de execução ao script:

```bash
chmod +x deploy_azure.sh
```

3. Execute o script:

```bash
./deploy_azure.sh
```

### Análise Detalhada do Script

A seguir, uma explicação de cada etapa realizada pelo script:

#### 1. Variáveis de Configuração

O script começa definindo variáveis para os nomes dos recursos. Isso centraliza a configuração, facilitando a personalização e evitando a repetição de nomes.

```bash
RESOURCE_GROUP="rg-displaycsv-azure-foods"
LOCATION="canadacentral"
APP_SERVICE_PLAN="asp-displaycsv-azure-foods"
WEBAPP_NAME="webapp-displaycsv-azure-foods"
# ... e outros ...
```

#### 2. Criação do Grupo de Recursos (`az group create`)

É o primeiro passo lógico. Um Grupo de Recursos é um contêiner que armazena todos os recursos relacionados a uma solução. Agrupá-los facilita o gerenciamento, o monitoramento de custos e a exclusão de todos os recursos de uma vez.

#### 3. Criação do Plano de Serviço (`az appservice plan create`)

Define a infraestrutura subjacente que hospedará o Web App.

- `--sku B1`: Especifica o tier de preço "Basic 1", que oferece um bom equilíbrio entre custo e recursos para aplicações de pequeno a médio porte.
- `--is-linux`: Provisiona uma máquina baseada em Linux, que é o ambiente padrão para aplicações Python modernas.

#### 4. Criação do Web App (`az webapp create`)

Cria a instância do serviço de aplicativo onde o código será executado.

- `--runtime "PYTHON:3.12"`: Configura o ambiente de execução para usar a versão 3.12 do Python, garantindo compatibilidade com o código da aplicação.
- `--plan $APP_SERVICE_PLAN`: Vincula o Web App ao plano de serviço criado anteriormente.

#### 5. Criação do Banco de Dados SQL (`az sql server create` e `az sql db create`)

Provisiona uma infraestrutura de banco de dados SQL completa.

- `az sql server firewall-rule create`: Um passo crítico de segurança. Aqui, a regra `AllowAzureServices` é criada com um intervalo de IP de 0.0.0.0 a 255.255.255.255, o que permite que qualquer serviço dentro da Azure acesse o banco de dados.

> **Nota**: A aplicação atual não utiliza o banco de dados, mas ele está incluído para demonstrar a criação de uma infraestrutura completa e escalável.

#### 6. Criação e Conexão do Application Insights (`az monitor app-insights ...`)

Configura a telemetria e o monitoramento da aplicação.

- `az monitor app-insights component create`: Cria o recurso do Application Insights.
- `az monitor app-insights component show ... --query connectionString`: Extrai a "Connection String" do recurso recém-criado.
- `az webapp config appsettings set`: Conecta o monitoramento ao Web App. Esta linha insere a Connection String nas configurações da aplicação, permitindo que o Azure monitore automaticamente o desempenho, detecte falhas e colete logs.

#### 7. Configuração do Deploy a partir do GitHub (`az webapp deployment source config`)

Esta é a etapa que configura a Integração Contínua (CI/CD).

- `--repo-url $GITHUB_REPO_URL`: Aponta para o repositório do GitHub que contém o código-fonte.
- `--branch main`: Define a branch `main` como a fonte para o deploy.
- `--manual-integration`: O Azure irá buscar o código do repositório. Quando esta configuração é feita, o Azure automaticamente inicia o primeiro deploy.

#### 8. Finalização

Ao final, o script exibe informações úteis, como a URL pública do Web App e o comando para visualizar os logs de deploy em tempo real, facilitando a verificação e o acesso à aplicação.

## 🌐 Como Usar a Aplicação

1. Acesse a URL da aplicação (local ou da Azure)
2. Clique em "Escolher arquivo" e selecione um arquivo `.csv` do seu computador
3. Clique em "Submit" (ou "Enviar")
4. A página será recarregada, exibindo o conteúdo do arquivo em uma tabela
5. Para visualizar outro arquivo, clique no link "Enviar outro arquivo"

---

**Desenvolvido por**: [RafaellSouzaPinto](https://github.com/RafaellSouzaPinto)

