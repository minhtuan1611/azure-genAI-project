# Deploy Azure OpenAI Service
resource "azurerm_cognitive_account" "openai_service" {
  name                = "cog-genai-service"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "OpenAI"
  sku_name            = "S0"
}

# Deploy GPT-4o-mini Model
resource "azurerm_cognitive_deployment" "gpt4o_mini_deployment" {
  name                 = "dep-gpt4o-mini"
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

# Deploy DALL-E 3 Model
resource "azurerm_cognitive_deployment" "dalle3_deployment" {
  name                 = "dall-e-3"
  cognitive_account_id = azurerm_cognitive_account.openai_service.id

  model {
    format  = "OpenAI"
    name    = "dall-e-3"
    version = "3.0"
  }

  sku {
    name     = "Standard"
    capacity = 1 # 1K Capacity Units (CU)
  }
}
