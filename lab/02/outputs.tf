output "webapp_default_hostname" {
  value = azurerm_linux_web_app.app.default_hostname
}

output "webapp_url" {
  value = "https://${azurerm_linux_web_app.app.default_hostname}"
}

output "private_dns_zone_name" {
  value = azurerm_private_dns_zone.webapp.name
}

output "private_endpoint_name" {
  value = azurerm_private_endpoint.webapp.name
}
