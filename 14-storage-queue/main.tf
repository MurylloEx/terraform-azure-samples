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

resource "azurerm_storage_account" "app_storage" {
  name                     = "${var.app_stage}${var.app_name}storage"
  resource_group_name      = azurerm_resource_group.app_group.name
  location                 = azurerm_resource_group.app_group.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind             = "StorageV2"

  tags = {
    Name  = var.app_name
    Stage = var.app_stage
  }
}

resource "azurerm_storage_queue" "example" {
  name                 = "${var.app_stage}-${var.app_name}-queue"
  storage_account_name = azurerm_storage_account.app_storage.name
}

