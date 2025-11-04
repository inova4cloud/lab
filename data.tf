########################################################
# Data sources to read A records across all zones (static RG)
########################################################

# Build all (zone, record) pairs using the static RG
locals {
  a_record_pairs = flatten([
    for zone_name in var.zones : [
      for r in var.a_record_names : {
        key  = "${zone_name}.${r}"
        name = r
        zone = zone_name
      }
    ]
  ])
}

data "azurerm_private_dns_a_record" "all_a_records" {
  for_each = {
    for pair in local.a_record_pairs : pair.key => pair
  }

  name                = each.value.name
  zone_name           = each.value.zone
  resource_group_name = var.resource_group_name
}

