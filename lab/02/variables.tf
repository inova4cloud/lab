variable "prefix" {
  type        = string
  description = "Short prefix used in resource names (max 2 chars to keep names under 15 chars)"
  default     = "02"

  validation {
    condition     = length(var.prefix) <= 2
    error_message = "prefix must be 2 characters or fewer to keep generated resource names under 15 characters."
  }
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

variable "bastion_subnet_cidr" {
  type        = string
  description = "Subnet CIDR for Azure Bastion subnet (must be /26 or larger)"
  default     = "10.20.2.0/26"
}

variable "jumpbox_subnet_cidr" {
  type        = string
  description = "Subnet CIDR for jumpbox VM used to test private web app access"
  default     = "10.20.3.0/24"
}

variable "jumpbox_vm_size" {
  type        = string
  description = "VM size for jumpbox"
  default     = "Standard_B1ms"
}

variable "jumpbox_image_sku" {
  type        = string
  description = "Windows Server image SKU for jumpbox"
  default     = "2022-datacenter"
}

variable "jumpbox_admin_username" {
  type        = string
  description = "Admin username for jumpbox VM"
  default     = "azureuser"
}

variable "jumpbox_admin_password" {
  type        = string
  description = "Admin password for Windows jumpbox VM"
  sensitive   = true
}

variable "webapp_public_access_enabled" {
  type        = bool
  description = "Enable or disable public network access to the web app"
  default     = false
}
