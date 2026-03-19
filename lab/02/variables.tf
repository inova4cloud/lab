variable "prefix" {
  type        = string
  description = "Lab name prefix for resources/groups"
  default     = "lab-02"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "westus2"
}

variable "app_service_sku_name" {
  type        = string
  description = "SKU for the App Service plan"
  default     = "B1"
}

variable "vnet_address_space" {
  type        = string
  description = "Address space for the virtual network hosting private endpoint integration"
  default     = "10.20.0.0/16"
}

variable "private_endpoint_subnet_cidr" {
  type        = string
  description = "Subnet CIDR for the web app private endpoint"
  default     = "10.20.1.0/24"
}

variable "webapp_public_access_enabled" {
  type        = bool
  description = "Enable or disable public network access to the web app"
  default     = false
}
