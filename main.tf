########################################################
# Variables
########################################################

variable "resource_group_name" {
  type        = string
  description = "Resource Group containing the Private DNS zones"
}

variable "zones" {
  type        = list(string)
  description = "List of Private DNS zone names to enumerate"
}

########################################################
# Outputs
########################################################

# Simplified list of record names per zone
output "record_names_by_zone" {
  description = "List of record names in each Private DNS zone"
  value = {
    for zone_name, records in local.zone_records :
    zone_name => [for r in records : r.name]
  }
}

# Full record payload (ARM JSON)
output "record_details_by_zone" {
  description = "Full ARM JSON of record sets per zone"
  value       = local.zone_records
  sensitive   = true
}
