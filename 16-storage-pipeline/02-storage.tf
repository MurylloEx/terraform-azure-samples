resource "azurerm_storage_account" "app_storage" {
  name                     = "${var.app_stage}${replace(var.app_name, "-", "")}storage"
  resource_group_name      = azurerm_resource_group.app_group.name
  location                 = azurerm_resource_group.app_group.location
  access_tier              = "Hot"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind             = "StorageV2"

  tags = {
    Name  = var.app_name
    Stage = var.app_stage
  }
}

resource "azurerm_storage_container" "app_src_storage_container" {
  name                  = "${var.app_stage}-${var.app_name}-src-container"
  storage_account_name  = azurerm_storage_account.app_storage.name
  container_access_type = "blob"
}

resource "azurerm_storage_container" "app_dest_storage_container" {
  name                  = "${var.app_stage}-${var.app_name}-dest-container"
  storage_account_name  = azurerm_storage_account.app_storage.name
  container_access_type = "blob"
}
