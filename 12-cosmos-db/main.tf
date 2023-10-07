terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.70"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
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

resource "random_string" "unique" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_cosmosdb_account" "app_cosmos_account" {
  name                      = "${var.app_stage}-${var.app_name}-cosmos-account-${random_string.unique.result}"
  location                  = azurerm_resource_group.app_group.location
  resource_group_name       = azurerm_resource_group.app_group.name
  offer_type                = "Standard"
  kind                      = "GlobalDocumentDB"
  enable_automatic_failover = false
  enable_free_tier          = true

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = azurerm_resource_group.app_group.location
    failover_priority = 0
  }

  capabilities {
    name = "EnableServerless"
  }
}

resource "azurerm_cosmosdb_sql_database" "app_cosmos_db" {
  name                = "${var.app_stage}-${var.app_name}-cosmos-db"
  account_name        = azurerm_cosmosdb_account.app_cosmos_account.name
  resource_group_name = azurerm_cosmosdb_account.app_cosmos_account.resource_group_name
}

resource "azurerm_cosmosdb_sql_container" "app_cosmos_container" {
  name                  = "${var.app_stage}-${var.app_name}-cosmos-container"
  database_name         = azurerm_cosmosdb_sql_database.app_cosmos_db.name
  account_name          = azurerm_cosmosdb_account.app_cosmos_account.name
  resource_group_name   = azurerm_cosmosdb_account.app_cosmos_account.resource_group_name
  partition_key_path    = "/PartitionKey"
  partition_key_version = 1

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }
  }
}
