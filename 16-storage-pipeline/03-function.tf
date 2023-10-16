resource "azurerm_application_insights" "app_insights" {
  name                = "${var.app_stage}-${var.app_name}-app-insights"
  location            = azurerm_resource_group.app_group.location
  resource_group_name = azurerm_resource_group.app_group.name
  application_type    = "Node.JS"

  tags = {
    Name  = var.app_name
    Stage = var.app_stage
  }
}

resource "azurerm_service_plan" "app_service_plan" {
  name                = "${var.app_stage}-${var.app_name}-service-plan"
  resource_group_name = azurerm_resource_group.app_group.name
  location            = azurerm_resource_group.app_group.location
  os_type             = "Linux"
  sku_name            = "Y1"

  tags = {
    Name  = var.app_name
    Stage = var.app_stage
  }
}

resource "azurerm_linux_function_app" "app_function" {
  name                = "${var.app_stage}-${var.app_name}-linux-function"
  resource_group_name = azurerm_resource_group.app_group.name
  location            = azurerm_resource_group.app_group.location

  storage_account_name       = azurerm_storage_account.app_storage.name
  storage_account_access_key = azurerm_storage_account.app_storage.primary_access_key
  service_plan_id            = azurerm_service_plan.app_service_plan.id

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"       = ""
    "FUNCTIONS_WORKER_RUNTIME"       = "node"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.app_insights.instrumentation_key,
    "StorageAccountConnectionString" = azurerm_storage_account.app_storage.primary_connection_string
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

  tags = {
    Name  = var.app_name
    Stage = var.app_stage
  }
}
