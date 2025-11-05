variable "resource_group_name" {
  type        = string
  description = "RG that contains the Private DNS zones"
}

variable "zones" {
  type        = list(string)
  description = "Private DNS zone names to enumerate"
}

# Final, simple outputs
output "record_names_by_zone" {
  value = { for z, recs in local.zone_records : z => [for r in recs : r.name] }
}

output "record_details_by_zone" {
  value     = local.zone_records   # full ARM JSON per record set
  sensitive = true
}

