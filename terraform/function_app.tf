# Create an App Service Plan (Consumption Plan)
resource "azurerm_service_plan" "app_service_plan" {
  name                = "asp-genai-linux"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

# Create Linux Function App
resource "azurerm_linux_function_app" "function_app" {
  name                       = "func-genai-openai"
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
    "DEPLOYMENT_NAME"                = "dep-gpt4o-mini"
    "API_VERSION"                    = "2025-01-01-preview"
    "WEBSITE_RUN_FROM_PACKAGE"       = "1"
    "FUNCTIONS_EXTENSION_VERSION"    = "~4"
  }
}
