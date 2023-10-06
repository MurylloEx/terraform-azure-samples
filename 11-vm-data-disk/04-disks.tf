resource "azurerm_managed_disk" "appdisk" {
  name                 = "${var.app_stage}-${var.app_name}-disk"
  location             = azurerm_resource_group.app_group.location
  resource_group_name  = azurerm_resource_group.app_group.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "8"

  tags = {
    Name  = var.app_name
    Stage = var.app_stage
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "appdiskattach" {
  managed_disk_id    = azurerm_managed_disk.appdisk.id
  virtual_machine_id = azurerm_linux_virtual_machine.app_linux_vm.id
  lun                = "0"
  caching            = "ReadWrite"
}
