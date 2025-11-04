variable "resource_group_name" {
  type        = string
  description = "RG that contains the DNS zones"
}

variable "zones" {
  type        = list(string)
  description = "Zone names to enumerate"
}

variable "zone_kind" {
  type        = string
  default     = "private"
  validation {
    condition     = contains(["private", "public"], var.zone_kind)
    error_message = "zone_kind must be \"private\" or \"public\"."
  }
}

output "record_names_by_zone" {
  value = {
    for zone_name, records in local.zone_records :
    zone_name => [for r in records : r.name]
  }
}

output "record_counts_by_zone_and_type" {
  value = local.record_counts
}

output "record_details_by_zone" {
  value     = local.zone_records
  sensitive = true
}

output "resolved_zone_ids" {
  value = { for k, z in local.zone_map : k => z.id }
}
