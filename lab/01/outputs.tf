output "lb_public_ip" {
  value = azurerm_public_ip.lb_pip.ip_address
}

output "lb_url" {
  value = "http://${azurerm_public_ip.lb_pip.ip_address}"
}
