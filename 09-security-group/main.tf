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

resource "azurerm_network_interface" "private_network_interface" {
  name                = "${var.app_stage}-${var.app_name}-private-nic"
  location            = azurerm_resource_group.app_group.location
  resource_group_name = azurerm_resource_group.app_group.name

  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.app_subnet_1.id
  }

  tags = {
    Name  = var.app_name
    Stage = var.app_stage
  }
}

resource "azurerm_public_ip" "public_ip_address" {
  name                = "${var.app_stage}-${var.app_name}-public-ip"
  resource_group_name = azurerm_resource_group.app_group.name
  location            = azurerm_resource_group.app_group.location
  allocation_method   = "Dynamic"

  tags = {
    Name  = var.app_name
    Stage = var.app_stage
  }
}

resource "azurerm_network_interface" "public_network_interface" {
  name                = "${var.app_stage}-${var.app_name}-public-nic"
  location            = azurerm_resource_group.app_group.location
  resource_group_name = azurerm_resource_group.app_group.name

  ip_configuration {
    name                          = "external"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip_address.id
    subnet_id                     = azurerm_subnet.app_subnet_2.id
  }

  tags = {
    Name  = var.app_name
    Stage = var.app_stage
  }
}

resource "azurerm_network_security_group" "app_security_group" {
  name                = "${var.app_stage}-${var.app_name}-security-group"
  location            = azurerm_resource_group.app_group.location
  resource_group_name = azurerm_resource_group.app_group.name

  security_rule {
    name                       = "AllowRDP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Name  = var.app_name
    Stage = var.app_stage
  }
}

resource "azurerm_subnet_network_security_group_association" "app_subnet_sg_association_1" {
  subnet_id                 = azurerm_subnet.app_subnet_1.id
  network_security_group_id = azurerm_network_security_group.app_security_group.id
}

resource "azurerm_subnet_network_security_group_association" "app_subnet_sg_association_2" {
  subnet_id                 = azurerm_subnet.app_subnet_2.id
  network_security_group_id = azurerm_network_security_group.app_security_group.id
}
