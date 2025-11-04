########################################################
# Variables
########################################################

variable "resource_group_name" {
  description = "Resource group that contains the DNS zones"
  type        = string
}

variable "zones" {
  description = "Zone names to enumerate (e.g., priv.east.contoso.local or contoso.com)"
  type        = list(string)
}

# "private" for Microsoft.Network/privateDnsZones
# "public"  for Microsoft.Network/dnsZones
variable "zone_kind" {
  description = "Type of Azure DNS zone: \"private\" or \"public\""
  type        = string
  default     = "private"
  validation {
    condition     = contains(["private", "public"], var.zone_kind)
    error_message = "zone_kind must be \"private\" or \"public\"."
  }
}

########################################################
# Outputs
########################################################

# Simple names list (per zone)
output "record_names_by_zone" {
  value = {
    for zone_name, records in local.zone_records :
    zone_name => [for r in records : r.name]
  }
}

# Helpful counts per zone/type
output "record_counts_by_zone_and_type" {
  value = local.record_counts
}

# Full JSON (for deep debugging / auditing)
output "record_details_by_zone" {
  value     = local.zone_records
  sensitive = true
}

# Debug: show zone IDs we actually queried
output "resolved_zone_ids" {
  value = { for k, z in local.zone_map : k => z.id }
}
