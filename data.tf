########################################################
# Resolve zones (private vs public) using the hub alias
########################################################

locals {
  is_private     = var.zone_kind == "private"
  zone_type_path = local.is_private ? "Microsoft.Network/privateDnsZones" : "Microsoft.Network/dnsZones"

  # API versions (stable) for record set "list" operations
  api_version_private = "2018-09-01"
  api_version_public  = "2018-05-01"

  api_version = local.is_private ? local.api_version_private : local.api_version_public

  # Supported record types for each service
  record_types = local.is_private
    ? ["A", "AAAA", "CNAME", "MX", "PTR", "SOA", "SRV", "TXT"]
    : ["A", "AAAA", "CAA", "CNAME", "MX", "NS", "PTR", "SOA", "SRV", "TXT"]
}

# Resolve zone resource IDs and basic metadata with azurerm data sources
# (Separate blocks because azurerm has distinct data resources for private vs public)
data "azurerm_private_dns_zone" "private_zones" {
  for_each = local.is_private ? toset(var.zones) : {}
  name                = each.value
  resource_group_name = var.resource_group_name
  provider            = azurerm.hub
}

data "azurerm_dns_zone" "public_zones" {
  for_each = local.is_private ? {} : toset(var.zones)
  name                = each.value
  resource_group_name = var.resource_group_name
  provider            = azurerm.hub
}

# Unified map of zones -> object with id & name
locals {
  zone_map = local.is_private
    ? { for k, v in data.azurerm_private_dns_zone.private_zones : k => { id = v.id, name = v.name } }
    : { for k, v in data.azurerm_dns_zone.public_zones          : k => { id = v.id, name = v.name } }
}

########################################################
# Enumerate record sets per (zone, type)
########################################################

# Build (zone,type) pairs
locals {
  zone_type_pairs = flatten([
    for zone_name, z in local.zone_map : [
      for rt in local.record_types : {
        key       = "${zone_name}:${rt}"
        zone_name = zone_name
        zone_id   = z.id
        type      = rt
      }
    ]
  ])
}

# List record sets per type via AzAPI
data "azapi_resource_list" "records" {
  for_each  = { for p in local.zone_type_pairs : p.key => p }
  type      = "${local.zone_type_path}/${each.value.type}@${local.api_version}"
  parent_id = each.value.zone_id
}

# Merge all types back per zone
locals {
  # Flatten per zone
  zone_records = {
    for zone_name, z in local.zone_map :
    zone_name => flatten([
      for rt in local.record_types :
      try(data.azapi_resource_list.records["${zone_name}:${rt}"].output.value, [])
    ])
  }

  # Counts by zone & type (good sanity check)
  record_counts = {
    for zone_name, z in local.zone_map :
    zone_name => {
      for rt in local.record_types :
      rt => length(try(data.azapi_resource_list.records["${zone_name}:${rt}"].output.value, []))
    }
  }
}
