output "webapp_default_hostname" {
  value = azurerm_linux_web_app.app.default_hostname
}

output "webapp_url" {
  value = "https://${azurerm_linux_web_app.app.default_hostname}"
}
