resource "azurerm_resource_group" "image_genai_rg" {
  name     = "image-genai-rg"
  location = var.location
}