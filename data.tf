locals {
  is_private         = var.zone_kind == "private"
  zone_type_path     = local.is_private ? "Microsoft.Network/privateDnsZones" : "Microsoft.Network/dnsZones"
  api_version        = local.is_private ? "2018-09-01" : "2018-05-01"
  record_types       = local.is_private
                        ? ["A", "AAAA", "CNAME", "MX", "PTR", "SOA", "SRV", "TXT"]
                        : ["A", "AAAA", "CAA", "CNAME", "MX", "NS", "PTR", "SOA", "SRV", "TXT"]
}

data "azurerm_private_dns_zone" "private_zones" {
  for_each            = local.is_private ? toset(var.zones) : {}
  name                = each.value
  resource_group_name = var.resource_group_name
  provider            = azurerm.hub
}

data "azurerm_dns_zone" "public_zones" {
  for_each            = local.is_private ? {} : toset(var.zones)
  name                = each.value
  resource_group_name = var.resource_group_name
  provider            = azurerm.hub
}

locals {
  zone_map = local.is_private
    ? { for k, v in data.azurerm_private_dns_zone.private_zones : k => { id = v.id, name = v.name } }
    : { for k, v in data.azurerm_dns_zone.public_zones          : k => { id = v.id, name = v.name } }

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

data "azapi_resource_list" "records" {
  for_each  = { for p in local.zone_type_pairs : p.key => p }
  type      = "${local.zone_type_path}/${each.value.type}@${local.api_version}"
  parent_id = each.value.zone_id
}

locals {
  zone_records = {
    for zone_name, z in local.zone_map :
    zone_name => flatten([
      for rt in local.record_types :
      try(data.azapi_resource_list.records["${zone_name}:${rt}"].output.value, [])
    ])
  }

  record_counts = {
    for zone_name, z in local.zone_map :
    zone_name => {
      for rt in local.record_types :
      rt => length(try(data.azapi_resource_list.records["${zone_name}:${rt}"].output.value, []))
    }
  }
}
