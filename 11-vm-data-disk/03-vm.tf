resource "tls_private_key" "ssh_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_private_key" {
  filename = "private-key.pem"
  content  = tls_private_key.ssh_key_pair.private_key_pem
}

data "cloudinit_config" "app_user_data" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = yamlencode({
      write_files = []
      runcmd = [
        "sudo apt-get update -y",
        "sudo apt-get upgrade -y",
        "sudo apt-get install apache2 -y"
      ]
    })
  }
}

resource "azurerm_linux_virtual_machine" "app_linux_vm" {
  name                            = "${var.app_stage}-${var.app_name}-linux-vm"
  resource_group_name             = azurerm_resource_group.app_group.name
  location                        = azurerm_resource_group.app_group.location
  network_interface_ids           = [azurerm_network_interface.public_network_interface.id]
  size                            = "Standard_D2s_v3"
  admin_username                  = "ubuntu"
  admin_password                  = "S3cr3t$"
  user_data                       = data.cloudinit_config.app_user_data.rendered
  disable_password_authentication = false

  admin_ssh_key {
    username   = "ubuntu"
    public_key = tls_private_key.ssh_key_pair.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  tags = {
    Name  = var.app_name
    Stage = var.app_stage
  }
}
