resource "azurerm_storage_account" "image_genai_storage" {
  name                     = "imagegenaistorage"
  resource_group_name      = azurerm_resource_group.image_genai_rg.name
  location                 = azurerm_resource_group.image_genai_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    cors_rule {
      allowed_origins    = ["https://happy-forest-063939003.6.azurestaticapps.net", "http://localhost:3000"]
      allowed_methods    = ["GET", "PUT", "POST", "DELETE", "HEAD", "OPTIONS"]
      max_age_in_seconds = 3600
      exposed_headers    = ["*"]
      allowed_headers    = ["*"]
    }
  }
}

resource "azurerm_storage_container" "upload-container" {
  name                  = "upload"
  storage_account_id    = azurerm_storage_account.image_genai_storage.id
  container_access_type = "blob"
}
