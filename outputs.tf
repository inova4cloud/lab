output "lb_public_ip" {
  value = azurerm_public_ip.lb_pip.ip_address
}

output "lb_url" {
  value = "http://${azurerm_public_ip.lb_pip.ip_address}"
}

output "storage_account_name" {
  value = azurerm_storage_account.logging.name
}

output "storage_account_primary_blob_endpoint" {
  value = azurerm_storage_account.logging.primary_blob_endpoint
}
