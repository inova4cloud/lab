terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

########################################################
# Variables
########################################################

# One static RG for all zones
variable "resource_group_name" {
  description = "Azure Resource Group that contains ALL of the Private DNS zones"
  type        = string
}

# List of Private DNS zone names (strings) under the static RG
variable "zones" {
  description = "Private DNS zone names to query (all in the same RG)"
  type        = list(string)
}

# A record names to fetch within each zone
variable "a_record_names" {
  description = "List of A record names to query per zone"
  type        = list(string)
  default     = ["api", "web"]
}

########################################################
# Outputs
########################################################

# Map: zone -> (record name -> list of IPs)
output "a_records_by_zone" {
  description = "Map of zone -> A record name -> list of IPs"
  value = {
    for zone_name in var.zones : zone_name => {
      for r in var.a_record_names :
      r => try(
        data.azurerm_private_dns_a_record.all_a_records["${zone_name}.${r}"].records,
        []
      )
    }
  }
}
