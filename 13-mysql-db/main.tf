terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.70"
    }
  }

  required_version = "~> 1.4"
}

provider "azurerm" {
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  features {}
}

resource "azurerm_resource_group" "app_group" {
  name     = "${var.app_stage}-${var.app_name}"
  location = var.azure_region
  tags = {
    Name  = var.app_name
    Stage = var.app_stage
  }
}

resource "azurerm_mysql_flexible_server" "app_mysql_server" {
  name                   = "${var.app_stage}-${var.app_name}-mysql-srv"
  resource_group_name    = azurerm_resource_group.app_group.name
  location               = azurerm_resource_group.app_group.location
  administrator_login    = "master"
  administrator_password = "H@Sh1CoR3!"
  backup_retention_days  = 7
  sku_name               = "GP_Standard_D2ds_v4"
  
  storage {
    size_gb = 20
  }
}

resource "azurerm_mysql_flexible_database" "app_mysql_database" {
  name                = "${var.app_stage}-${var.app_name}-mysql-db"
  resource_group_name = azurerm_resource_group.app_group.name
  server_name         = azurerm_mysql_flexible_server.app_mysql_server.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}
