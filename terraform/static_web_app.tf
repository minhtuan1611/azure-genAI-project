resource "azurerm_static_web_app" "image_genai_app" {
  name                = "image-genai-app"
  location            = azurerm_resource_group.image_genai_rg.location
  resource_group_name = azurerm_resource_group.image_genai_rg.name
  sku_tier            = "Standard"
  sku_size            = "Standard"

  # GitHub Repository details for private repo access
  repository_url     = "https://github.com/minhtuan1611/image-genai-frontend"
  repository_branch  = "main"
  repository_token   = var.github_token

}
