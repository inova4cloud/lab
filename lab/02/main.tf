

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

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_address_space]

  tags = {
    env = "${var.prefix}-webapp"
  }
}

resource "azurerm_subnet" "private_endpoint" {
  name                 = "${var.prefix}-pep-snet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.private_endpoint_subnet_cidr]

  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_linux_web_app" "app" {
  name                = "${var.prefix}-webapp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id
  https_only          = true
  public_network_access_enabled = var.webapp_public_access_enabled

  site_config {
    always_on = true

    application_stack {
      docker_image_name   = "mcr.microsoft.com/azuredocs/aci-helloworld"
      docker_registry_url = "https://mcr.microsoft.com"
    }
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITES_PORT                       = "80"
  }

  tags = {
    env = "${var.prefix}-webapp"
  }
}

resource "azurerm_private_dns_zone" "webapp" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    env = "${var.prefix}-webapp"
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "webapp" {
  name                  = "${var.prefix}-webapp-dnslink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.webapp.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_endpoint" "webapp" {
  name                = "${var.prefix}-webapp-pep"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.private_endpoint.id

  private_service_connection {
    name                           = "${var.prefix}-webapp-psc"
    private_connection_resource_id = azurerm_linux_web_app.app.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }

  private_dns_zone_group {
    name                 = "webapp-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.webapp.id]
  }

  tags = {
    env = "${var.prefix}-webapp"
  }
}
