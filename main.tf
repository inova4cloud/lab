terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
  }
}

# Provider alias for hub context
provider "azurerm" {
  alias    = "hub"
  features {}
}

provider "azapi" {}

########################################################
# Variables
########################################################

variable "resource_group_name" {
  description = "Static resource group name containing the private DNS zones"
  type        = string
}

variable "zones" {
  description = "List of Private DNS zone names to enumerate"
  type        = list(string)
}

########################################################
# Outputs
########################################################

output "record_names_by_zone" {
  description = "Simplified map of zone -> record names"
  value = {
    for zone_name, records in local.zone_records :
    zone_name => [for r in records : r.name]
  }
}

output "record_details_by_zone" {
  description = "Detailed list of record JSON objects per zone"
  value       = local.zone_records
  sensitive   = true # may contain internal IPs or metadata
}
