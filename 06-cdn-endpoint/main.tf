terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3.70"
    }

    random = {
      source = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  required_version = "~> 1.4"
}

provider "azurerm" {
  subscription_id = var.azure_subscription_id
  tenant_id = var.azure_tenant_id
  client_id = var.azure_client_id
  client_secret = var.azure_client_secret
  features {}
}

resource "azurerm_resource_group" "app_group" {
  name     = "${var.app_stage}-${var.app_name}"
  location = var.azure_region
  tags = {
    Name = var.app_name
    Stage = var.app_stage
  }
}

resource "azurerm_storage_account" "app_storage" {
  name                      = "${var.app_stage}${var.app_name}storage"
  resource_group_name       = azurerm_resource_group.app_group.name
  location                  = azurerm_resource_group.app_group.location
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  account_kind              = "StorageV2"
  min_tls_version           = "TLS1_2"
  enable_https_traffic_only = true

  blob_properties {
    cors_rule {
      allowed_origins    = ["*"]
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "POST", "PUT", "DELETE"]
      exposed_headers    = ["ETag"]
      max_age_in_seconds = 3000
    }
  }

  static_website {
    index_document = "index.html"
    error_404_document = "404.html"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Name = var.app_name
    Stage = var.app_stage
  }
}

resource "azurerm_storage_blob" "index_blob_object" {
  name                    = "index.html"
  storage_account_name    = azurerm_storage_account.app_storage.name
  storage_container_name  = "$web"
  type                    = "Block"
  source_content          = "Hello world!"
  content_type            = "text/html"
}

resource "azurerm_storage_blob" "not_found_blob_object" {
  name                    = "404.html"
  storage_account_name    = azurerm_storage_account.app_storage.name
  storage_container_name  = "$web"
  type                    = "Block"
  source_content          = "Not found!"
  content_type            = "text/html"
}

resource "azurerm_cdn_profile" "cdn_profile" {
  name                = "${var.app_stage}-${var.app_name}-cdn"
  resource_group_name = azurerm_resource_group.app_group.name
  location            = azurerm_resource_group.app_group.location
  sku                 = "Standard_Microsoft"
  tags                = {
    Name = var.app_name
    Stage = var.app_stage
  }
}

resource "random_string" "unique" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_cdn_endpoint" "cdn_endpoint" {
  name                          = random_string.unique.result
  profile_name                  = azurerm_cdn_profile.cdn_profile.name
  location                      = azurerm_resource_group.app_group.location
  resource_group_name           = azurerm_resource_group.app_group.name
  origin_host_header            = azurerm_storage_account.app_storage.primary_web_host
  querystring_caching_behaviour = "IgnoreQueryString"
  is_http_allowed               = false 
  is_compression_enabled        = true

  origin {
    name      = "origin-${random_string.unique.result}"
    host_name = azurerm_storage_account.app_storage.primary_web_host
  }

  tags = {
    Name = var.app_name
    Stage = var.app_stage
  }
}

