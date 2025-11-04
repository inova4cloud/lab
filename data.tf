########################################################
# Enumerate all record sets across multiple zones
# (looping over each record type, then merging)
########################################################

# 1) Resolve each zone (uses provider alias "hub")
data "azurerm_private_dns_zone" "zones" {
  for_each = toset(var.zones)

  name                = each.value
  resource_group_name = var.resource_group_name
  provider            = azurerm.hub
}

# 2) Record types to enumerate (Private DNS supports these)
locals {
  record_types = ["A", "AAAA", "CNAME", "MX", "PTR", "SOA", "SRV", "TXT"]
}

# 3) Build (zone,type) combinations
locals {
  zone_type_pairs = flatten([
    for zone_name, z in data.azurerm_private_dns_zone.zones : [
      for rt in local.record_types : {
        key       = "${zone_name}:${rt}"
        zone_name = zone_name
        zone_id   = z.id
        type      = rt
      }
    ]
  ])
}

# 4) List records per (zone,type) with AzAPI
data "azapi_resource_list" "records" {
  for_each  = { for p in local.zone_type_pairs : p.key => p }
  type      = "Microsoft.Network/privateDnsZones/${each.value.type}@2018-09-01"
  parent_id = each.value.zone_id
}

# 5) Merge per zone
locals {
  zone_records = {
    for zone_name, _ in data.azurerm_private_dns_zone.zones :
    zone_name => flatten([
      for rt in local.record_types :
      try(data.azapi_resource_list.records["${zone_name}:${rt}"].output.value, [])
    ])
  }
}
