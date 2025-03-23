resource "azurerm_static_web_app" "nextjs_app" {
  name                = "nextjs-app"
  location            = azurerm_resource_group.rg-web-app.location
  resource_group_name = azurerm_resource_group.rg-web-app.name
  sku_tier            = "Standard"
  sku_size            = "Standard"

  # GitHub Repository details for private repo access
  repository_url     = "https://github.com/minhtuan1611/shirt-ai-frontend"
  repository_branch  = "main"
  repository_token   = var.github_token

}

# Output the URL of the deployed Static Web App
output "static_web_app_url" {
  value = azurerm_static_web_app.nextjs_app.default_host_name
}
