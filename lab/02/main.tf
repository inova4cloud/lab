

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location

  tags = {
    env = "${var.prefix}-webapp"
  }
}

resource "azurerm_service_plan" "plan" {
  name                = "${var.prefix}-asp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = var.app_service_sku_name

  tags = {
    env = "${var.prefix}-webapp"
  }
}

resource "azurerm_linux_web_app" "app" {
  name                = "${var.prefix}-webapp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id
  https_only          = true

  site_config {
    always_on = false

    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  }

  tags = {
    env = "${var.prefix}-webapp"
  }
}
