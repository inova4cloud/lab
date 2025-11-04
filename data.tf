########################################################
# Enumerate all record sets in each Private DNS zone
########################################################

# Get zone resource IDs
data "azurerm_private_dns_zone" "zones" {
  for_each = toset(var.zones)

  name                = each.value
  resource_group_name = var.resource_group_name
  provider            = azurerm.hub
}

# List all records for each zone
data "azapi_resource_list" "all_records" {
  for_each  = data.azurerm_private_dns_zone.zones
  type      = "Microsoft.Network/privateDnsZones/ALL@2018-09-01"
  parent_id = each.value.id
}

# Collect outputs for readability
locals {
  zone_records = {
    for zone_name, record_list in data.azapi_resource_list.all_records :
    zone_name => try(record_list.output.value, [])
  }
}
