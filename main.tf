output "record_names_by_zone" {
  description = "Simplified map of zone -> record names"
  value = {
    for zone_name, records in local.zone_records :
    zone_name => [for r in records : r.name]
  }
}

output "record_details_by_zone" {
  description = "Detailed JSON of all record sets per zone"
  value       = local.zone_records
  sensitive   = true
}
