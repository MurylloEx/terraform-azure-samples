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

resource "azurerm_virtual_network" "app_virtual_network" {
  name                = "${var.app_stage}-${var.app_name}-network"
  location            = azurerm_resource_group.app_group.location
  resource_group_name = azurerm_resource_group.app_group.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    Name  = var.app_name
    Stage = var.app_stage
  }
}

resource "azurerm_subnet" "app_subnet_1" {
  name                 = "${var.app_stage}-${var.app_name}-subnet-1"
  resource_group_name  = azurerm_resource_group.app_group.name
  virtual_network_name = azurerm_virtual_network.app_virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "app_subnet_2" {
  name                 = "${var.app_stage}-${var.app_name}-subnet-2"
  resource_group_name  = azurerm_resource_group.app_group.name
  virtual_network_name = azurerm_virtual_network.app_virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

