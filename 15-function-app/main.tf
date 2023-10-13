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

resource "azurerm_storage_container" "app_storage_container" {
  name                  = "${var.app_stage}-${var.app_name}-container"
  storage_account_name  = azurerm_storage_account.app_storage.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "blob_object" {
  name                   = "${var.app_stage}-${var.app_name}-file.txt"
  storage_account_name   = azurerm_storage_account.app_storage.name
  storage_container_name = azurerm_storage_container.app_storage_container.name
  type                   = "Block"
  source_content         = "Hello world!"
}

resource "azurerm_application_insights" "app_insights" {
  name                = "${var.app_stage}-${var.app_name}-application-insights"
  location            = azurerm_resource_group.app_group.location
  resource_group_name = azurerm_resource_group.app_group.name
  application_type    = "Node.JS"
}

resource "azurerm_service_plan" "app_service_plan" {
  name                = "${var.app_stage}-${var.app_name}-service-plan"
  resource_group_name = azurerm_resource_group.app_group.name
  location            = azurerm_resource_group.app_group.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "app_function" {
  name                = "${var.app_stage}-${var.app_name}-linux-function"
  resource_group_name = azurerm_resource_group.app_group.name
  location            = azurerm_resource_group.app_group.location

  storage_account_name       = azurerm_storage_account.app_storage.name
  storage_account_access_key = azurerm_storage_account.app_storage.primary_access_key
  service_plan_id            = azurerm_service_plan.app_service_plan.id

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = ""
    "FUNCTIONS_WORKER_RUNTIME" = "node"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.app_insights.instrumentation_key,
  }

  site_config {
    use_32_bit_worker = false

    application_stack {
      node_version = "16"
    }
    cors {
      allowed_origins = ["*"]
    }
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
    ]
  }
}

resource "azurerm_linux_function_app_slot" "app_function_slot" {
  name                 = "slot1"
  function_app_id      = azurerm_linux_function_app.app_function.id
  storage_account_name = azurerm_storage_account.app_storage.name

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = ""
    "FUNCTIONS_WORKER_RUNTIME" = "node"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.app_insights.instrumentation_key,
  }

  site_config {
    use_32_bit_worker = false

    application_stack {
      node_version = "16"
    }
    cors {
      allowed_origins = ["*"]
    }
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
    ]
  }
}
