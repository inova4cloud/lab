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

output "bastion_host_name" {
  value = azurerm_bastion_host.this.name
}

output "jumpbox_private_ip" {
  value = azurerm_network_interface.jumpbox.private_ip_address
}

output "jumpbox_admin_username" {
  value = var.jumpbox_admin_username
}

output "jumpbox_os_type" {
  value = "windows"
}
