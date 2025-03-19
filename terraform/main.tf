provider "azurerm" {
  features {}

  subscription_id = "your-subscription-id"
  client_id       = "your-client-id"
  client_secret   = "your-client-secret"
  tenant_id       = "your-tenant-id"
}
# Create a Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "ai-gpt4o-mini-rg"
  location = "East US 2"
}

# Deploy Azure OpenAI Service
resource "azurerm_cognitive_account" "openai_service" {
  name                = "gpt4o-mini-service"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "OpenAI"
  sku_name            = "S0" # This is correct for the Cognitive Account
}

# Deploy GPT-4o-mini Model
resource "azurerm_cognitive_deployment" "gpt4o_mini_deployment" {
  name                 = "gpt-4o-mini-test"
  cognitive_account_id = azurerm_cognitive_account.openai_service.id

  model {
    format  = "OpenAI"
    name    = "gpt-4o-mini"
    version = "2024-07-18"
  }

  sku {
    name     = "Standard"
    capacity = 1
  }
}

# Output the API Endpoint
output "openai_endpoint" {
  value = azurerm_cognitive_account.openai_service.endpoint
}
