resource "azurerm_service_plan" "app_service_plan" {
  name                = "upload-asp"
  resource_group_name = azurerm_resource_group.rg-web-app.name
  location            = azurerm_resource_group.rg-web-app.location
  os_type             = "Linux"
  sku_name            = "Y1"
}


resource "azurerm_linux_function_app" "function_app" {
  name                       = "sas-generate-function-app"
  location                   = azurerm_resource_group.rg-web-app.location
  resource_group_name        = azurerm_resource_group.rg-web-app.name
  service_plan_id            = azurerm_service_plan.app_service_plan.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key

  identity {
    type = "SystemAssigned"
  }

  site_config {
    minimum_tls_version = "1.2"
    application_stack {
      node_version = "20"
    }
    cors{
      allowed_origins = ["https://kind-dune-00d514203.6.azurestaticapps.net", "http://localhost:3000"]
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"       = "node"
    "WEBSITE_NODE_DEFAULT_VERSION"   = "~20"
    "WEBSITE_RUN_FROM_PACKAGE"       = "1"
    "FUNCTIONS_EXTENSION_VERSION"    = "~4"
  }
}