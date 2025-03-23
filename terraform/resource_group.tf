resource "azurerm_resource_group" "rg" {
  name     = "rg-genai-sweden-central"
  location = "Sweden Central"
}
resource "azurerm_resource_group" "rg-web-app" {
  name     = "rg-genai-west-europe"
  location = "West Europe"
}