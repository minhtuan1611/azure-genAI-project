

resource "azurerm_storage_account" "storage" {
  name                     = "upandgenimagestorage"
  resource_group_name      = azurerm_resource_group.rg-web-app.name
  location                 = azurerm_resource_group.rg-web-app.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    cors_rule {
      allowed_origins    = ["https://kind-dune-00d514203.6.azurestaticapps.net", "http://localhost:3000"]
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
