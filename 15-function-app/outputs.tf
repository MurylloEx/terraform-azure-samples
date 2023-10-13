output "function_app_name" {
  value = azurerm_linux_function_app.app_function.name
  description = "Deployed function app name"
}

output "function_app_default_hostname" {
  value = azurerm_linux_function_app.app_function.default_hostname
  description = "Deployed function app hostname"
}

output "function_app_slot_default_hostname" {
  value = azurerm_linux_function_app_slot.app_function_slot.default_hostname
  description = "Deployed function app slot hostname"
}
