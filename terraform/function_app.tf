resource "azurerm_service_plan" "image_genai_asp" {
  name                = "image-genai-asp"
  resource_group_name = azurerm_resource_group.image_genai_rg.name
  location            = azurerm_resource_group.image_genai_rg.location
  os_type             = "Linux"
  sku_name            = "Y1"
}


resource "azurerm_linux_function_app" "image_genai_function" {
  name                       = "image-genai-function-app"
  location                   = azurerm_resource_group.image_genai_rg.location
  resource_group_name        = azurerm_resource_group.image_genai_rg.name
  service_plan_id            = azurerm_service_plan.image_genai_asp.id
  storage_account_name       = azurerm_storage_account.image_genai_storage.name
  storage_account_access_key = azurerm_storage_account.image_genai_storage.primary_access_key
  depends_on = [
    azurerm_storage_account.image_genai_storage
  ]

  identity {
    type = "SystemAssigned"
  }

  site_config {
    minimum_tls_version = "1.2"
    application_stack {
      node_version = "20"
    }
    cors{
      allowed_origins = ["https://happy-forest-063939003.6.azurestaticapps.net", "http://localhost:3000"]
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"       = "node"
    "WEBSITE_NODE_DEFAULT_VERSION"   = "~20"
    "WEBSITE_RUN_FROM_PACKAGE"       = "1"
    "FUNCTIONS_EXTENSION_VERSION"    = "~4"
  }
}