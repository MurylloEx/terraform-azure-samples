output "resource_group_id" {
  value       = azurerm_resource_group.app_group.id
  description = "Id do grupo de recursos."
}

output "resource_group_name" {
  value       = azurerm_resource_group.app_group.name
  description = "Nome do grupo de recursos."
}

output "storage_account_id" {
  value       = azurerm_storage_account.app_storage.id
  description = "Id da conta de armazenamento."
}

output "storage_account_connection_string" {
  value       = azurerm_storage_account.app_storage.primary_connection_string
  description = "String de conexão da conta de armazenamento."
  sensitive   = false
}

output "source_storage_container_id" {
  value       = azurerm_storage_container.app_src_storage_container.id
  description = "Id do contêiner de entrada dos dados da pipeline."
}

output "destination_storage_container_id" {
  value       = azurerm_storage_container.app_dest_storage_container.id
  description = "Id do contêiner de saída dos dados da pipeline."
}

output "function_app_id" {
  value       = azurerm_linux_function_app.app_function.name
  description = "Id da Azure Function da pipeline."
}

output "function_app_name" {
  value       = azurerm_linux_function_app.app_function.name
  description = "Nome da Azure Function da pipeline."
}

output "function_app_default_hostname" {
  value       = azurerm_linux_function_app.app_function.default_hostname
  description = "Nome de host (hostname) da Azure Function da pipeline."
}

