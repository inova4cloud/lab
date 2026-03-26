output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "webapp_name" {
  value = azurerm_linux_web_app.app.name
}

output "webapp_url" {
  value = "https://${azurerm_linux_web_app.app.default_hostname}"
}

output "app_gateway_public_ip" {
  value = azurerm_public_ip.appgw.ip_address
}

output "app_gateway_url" {
  value = "https://${azurerm_public_ip.appgw.ip_address}"
}
