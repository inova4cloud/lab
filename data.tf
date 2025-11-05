########################################################
# Enumerate all record sets per Private DNS zone
########################################################

# Step 1: Resolve each Private DNS zone
data "azurerm_private_dns_zone" "zones" {
  for_each            = toset(var.zones)
  name                = each.value
  resource_group_name = var.resource_group_name
  provider            = azurerm.hub
}

# Step 2: Supported record types (Private DNS)
locals {
  api_version  = "2018-09-01"
  record_types = ["A", "AAAA", "CNAME", "MX", "PTR", "SOA", "SRV", "TXT"]
}

# Step 3: Build (zone, type) combinations
locals {
  pairs = flatten([
    for zn, z in data.azurerm_private_dns_zone.zones : [
      for rt in local.record_types : {
        key = "${zn}:${rt}"
        id  = z.id
        rt  = rt
        zn  = zn
      }
    ]
  ])
}

# Step 4: List record sets per type via AzAPI
data "azapi_resource_list" "records" {
  for_each  = { for p in local.pairs : p.key => p }
  type      = "Microsoft.Network/privateDnsZones/${each.value.rt}@${local.api_version}"
  parent_id = each.value.id
}

# Step 5: Flatten back per zone
locals {
  zone_records = {
    for zn, _ in data.azurerm_private_dns_zone.zones :
    zn => flatten([
      for rt in local.record_types :
      try(data.azapi_resource_list.records["${zn}:${rt}"].output.value, [])
    ])
  }
}
