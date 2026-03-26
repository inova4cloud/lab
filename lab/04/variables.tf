variable "prefix" {
  type        = string
  description = "Short prefix for resource names"
  default     = "l4"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "centralus"
}

variable "app_service_sku_name" {
  type        = string
  description = "SKU for the App Service plan"
  default     = "B1"
}

variable "python_version" {
  type        = string
  description = "Python runtime version for App Service"
  default     = "3.11"
}

variable "app_name_suffix" {
  type        = string
  description = "Suffix used to keep web app names unique"
  default     = "pyhello"
}

variable "appgw_capacity" {
  type        = number
  description = "Application Gateway instance count"
  default     = 1
}

variable "appgw_ssl_cert_base64" {
  type        = string
  description = "Base64-encoded PFX certificate for the Application Gateway HTTPS listener"
  sensitive   = true
}

variable "appgw_ssl_cert_password" {
  type        = string
  description = "Password for the Application Gateway PFX certificate"
  sensitive   = true
  default     = "ChangeThisPassword!" # Default value for testing; replace with secure password in production
}
