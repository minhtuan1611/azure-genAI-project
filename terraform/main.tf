provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "openai_api_key" {}

# Create a Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "ai-gpt4o-mini-rg"
  location = "East US 2"
}

# Create Application Insights for logging
resource "azurerm_application_insights" "app_insights" {
  name                = "ai-gpt4o-mini-insights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}


# Deploy Azure OpenAI Service
resource "azurerm_cognitive_account" "openai_service" {
  name                = "gpt4o-mini-service"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "OpenAI"
  sku_name            = "S0"
}

# Deploy GPT-4o-mini Model
resource "azurerm_cognitive_deployment" "gpt4o_mini_deployment" {
  name                 = "gpt-4o-mini-test"
  cognitive_account_id = azurerm_cognitive_account.openai_service.id

  model {
    format  = "OpenAI"
    name    = "gpt-4o-mini"
    version = "2024-07-18"
  }

  sku {
    name     = "Standard"
    capacity = 1
  }
}

# Create a Storage Account for Function App
resource "azurerm_storage_account" "storage" {
  name                     = "storageazuregenai"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create an App Service Plan (Consumption Plan)
resource "azurerm_service_plan" "app_service_plan" {
  name                = "aifunctionplan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "Y1"  # Change to "B1" for Basic Plan
}
# Update the Function App to enable Application Insights
resource "azurerm_linux_function_app" "function_app" {
  name                       = "aiopenaifunction"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  service_plan_id            = azurerm_service_plan.app_service_plan.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key

  identity {
    type = "SystemAssigned"
  }

  site_config {
    minimum_tls_version = "1.2"
    application_stack {
      node_version = "20"  # Set Node.js 20 runtime
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"       = "node"
    "WEBSITE_NODE_DEFAULT_VERSION"   = "~20"  # Ensure Node.js 20 is set
    "OPENAI_API_KEY"                 = var.openai_api_key
    "OPENAI_ENDPOINT"                = "https://tuan-m8focyel-eastus2.openai.azure.com"
    "DEPLOYMENT_NAME"                = "gpt-4o-mini-test"
    "API_VERSION"                    = "2025-01-01-preview"
    "WEBSITE_RUN_FROM_PACKAGE"       = "1"
    "FUNCTIONS_EXTENSION_VERSION"    = "~4"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.app_insights.connection_string
  }
}


# Output Function App URL
output "function_app_url" {
  value = "https://${azurerm_linux_function_app.function_app.default_hostname}"
}
