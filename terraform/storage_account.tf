

resource "azurerm_storage_account" "storage" {
  name                     = "upandgenimagestorage"
  resource_group_name      = azurerm_resource_group.rg-web-app.name
  location                 = azurerm_resource_group.rg-web-app.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    cors_rule {
      allowed_origins    = ["*"]
      allowed_methods    = ["GET", "PUT", "POST", "DELETE", "HEAD", "OPTIONS"]
      max_age_in_seconds = 3600
      exposed_headers    = ["*"]
      allowed_headers    = ["*"]
    }
  }
}

resource "azurerm_storage_container" "upload-container" {
  name                  = "upload"
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "blob"
}

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
      allowed_origins = ["*"]
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"       = "node"
    "WEBSITE_NODE_DEFAULT_VERSION"   = "~20"
    "WEBSITE_RUN_FROM_PACKAGE"       = "1"
    "FUNCTIONS_EXTENSION_VERSION"    = "~4"
  }
}