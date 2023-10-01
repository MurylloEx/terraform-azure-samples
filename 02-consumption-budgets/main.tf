terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3.70"
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

resource "azurerm_monitor_action_group" "app_monitor_action_group" {
  name                = "${var.app_stage}-${var.app_name}-monitor-action"
  resource_group_name = azurerm_resource_group.app_group.name
  short_name          = "Budget Alert"

  tags = {
    Name = var.app_name
    Stage = var.app_stage
  }
}

resource "azurerm_consumption_budget_resource_group" "example" {
  name              = "${var.app_stage}-${var.app_name}-consumption-budget"
  resource_group_id = azurerm_resource_group.app_group.id

  amount     = 5
  time_grain = "Monthly"

  time_period {
    start_date = "2023-10-01T00:00:00Z"
    end_date   = "2024-10-01T00:00:00Z"
  }

  filter {
    dimension {
      name = "ResourceId"
      values = [azurerm_monitor_action_group.app_monitor_action_group.id]
    }

    tag {
      name = "TagName"
      values = [
        "Tag Value 1",
        "Tag Value 2",
      ]
    }
  }

  notification {
    enabled        = true
    threshold      = 4.0
    operator       = "EqualTo"
    threshold_type = "Actual"

    contact_groups = [azurerm_monitor_action_group.app_monitor_action_group.id]
    contact_emails = ["muryllopimenta@gmail.com"]
    contact_roles = ["Owner"]
  }

  notification {
    enabled   = false
    threshold = 5.0
    operator  = "GreaterThan"
    threshold_type = "Forecasted"

    contact_groups = [azurerm_monitor_action_group.app_monitor_action_group.id]
    contact_emails = ["muryllopimenta@gmail.com"]
  }
}
