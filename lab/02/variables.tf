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
