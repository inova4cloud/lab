resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location

  tags = {
    lab = "03"
  }
}

resource "azurerm_service_plan" "plan" {
  name                = "${var.prefix}-asp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = var.app_service_sku_name

  tags = {
    lab = "03"
  }
}

resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

resource "random_string" "sql_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "random_password" "sql_admin" {
  length           = 20
  special          = true
  min_special      = 2
  override_special = "!@#%^*_-"
}

data "azurerm_client_config" "current" {}

resource "azurerm_mssql_server" "sql" {
  name                         = "${var.prefix}sql${random_string.sql_suffix.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = random_password.sql_admin.result

  azuread_administrator {
    login_username              = var.sql_entra_admin_login
    object_id                   = var.sql_entra_admin_object_id
    tenant_id                   = coalesce(var.sql_entra_admin_tenant_id, data.azurerm_client_config.current.tenant_id)
    azuread_authentication_only = true
  }

  tags = {
    lab = "03"
  }
}

resource "azurerm_mssql_database" "db" {
  name      = var.sql_database_name
  server_id = azurerm_mssql_server.sql.id
  sku_name  = "Basic"

  tags = {
    lab = "03"
  }
}

resource "azurerm_mssql_firewall_rule" "allow_azure" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_linux_web_app" "app" {
  name                = "${var.prefix}-${var.app_name_suffix}-${random_integer.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id
  https_only          = true

  site_config {
    always_on = false
    app_command_line = "gunicorn --bind=0.0.0.0:$PORT app:app"

    application_stack {
      python_version = var.python_version
    }
  }

  app_settings = {
    SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
    SQL_SERVER_FQDN                = azurerm_mssql_server.sql.fully_qualified_domain_name
    SQL_DATABASE                   = azurerm_mssql_database.db.name
  }

  tags = {
    lab = "03"
  }
}
