# Output Function App URL
output "function_app_url" {
  value = "https://${azurerm_linux_function_app.function_app.default_hostname}"
}
