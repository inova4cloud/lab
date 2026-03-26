resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location

  tags = {
    lab = "04"
  }
}

resource "azurerm_service_plan" "plan" {
  name                = "${var.prefix}-asp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = var.app_service_sku_name

  tags = {
    lab = "04"
  }
}

resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

resource "azurerm_linux_web_app" "app" {
  name                = "${var.prefix}-${var.app_name_suffix}-${random_integer.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id
  https_only          = true

  site_config {
    always_on               = false
    app_command_line        = "gunicorn --bind=0.0.0.0:$PORT app:app"
    minimum_tls_version     = "1.2"
    scm_minimum_tls_version = "1.2"

    application_stack {
      python_version = var.python_version
    }
  }

  app_settings = {
    SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
  }

  tags = {
    lab = "04"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.40.0.0/16"]

  tags = {
    lab = "04"
  }
}

resource "azurerm_subnet" "appgw" {
  name                 = "appgw-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.40.1.0/24"]
}

resource "azurerm_public_ip" "appgw" {
  name                = "${var.prefix}-appgw-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    lab = "04"
  }
}

resource "azurerm_application_gateway" "appgw" {
  name                = "${var.prefix}-appgw"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = var.appgw_capacity
  }

  ssl_policy {
    policy_type          = "Predefined"
    policy_name          = "AppGwSslPolicy20220101S"
    min_protocol_version = "TLSv1_2"
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_port {
    name = "fe-port-443"
    port = 443
  }

  frontend_port {
    name = "fe-port-80"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "fe-ip-config"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  ssl_certificate {
    name     = "gateway-cert"
    data     = var.appgw_ssl_cert_base64
    password = var.appgw_ssl_cert_password
  }

  backend_address_pool {
    name  = "appsvc-pool"
    fqdns = [azurerm_linux_web_app.app.default_hostname]
  }

  backend_http_settings {
    name                                = "appsvc-https"
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 60
    pick_host_name_from_backend_address = true
    probe_name                          = "appsvc-probe"
  }

  probe {
    name                                      = "appsvc-probe"
    protocol                                  = "Https"
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
    match {
      status_code = ["200-399"]
    }
  }

  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "fe-ip-config"
    frontend_port_name             = "fe-port-443"
    protocol                       = "Https"
    ssl_certificate_name           = "gateway-cert"
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "fe-ip-config"
    frontend_port_name             = "fe-port-80"
    protocol                       = "Http"
  }

  redirect_configuration {
    name                 = "http-to-https"
    redirect_type        = "Permanent"
    target_listener_name = "https-listener"
    include_path         = true
    include_query_string = true
  }

  request_routing_rule {
    name                        = "http-redirect-rule"
    rule_type                   = "Basic"
    priority                    = 90
    http_listener_name          = "http-listener"
    redirect_configuration_name = "http-to-https"
  }

  request_routing_rule {
    name                       = "https-backend-rule"
    rule_type                  = "Basic"
    priority                   = 100
    http_listener_name         = "https-listener"
    backend_address_pool_name  = "appsvc-pool"
    backend_http_settings_name = "appsvc-https"
  }

  tags = {
    lab = "04"
  }

  depends_on = [azurerm_linux_web_app.app]
}
