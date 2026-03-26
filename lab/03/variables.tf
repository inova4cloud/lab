variable "prefix" {
  type        = string
  description = "Short prefix for resource names"
  default     = "l3"
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

variable "sql_admin_username" {
  type        = string
  description = "Administrator username for Azure SQL Server"
  default     = "sqladminuser"
}

variable "sql_database_name" {
  type        = string
  description = "Database name for MOTD table"
  default     = "motddb"
}

variable "sql_entra_admin_login" {
  type        = string
  description = "Entra admin login (UPN/display name) for SQL Server"
}

variable "sql_entra_admin_object_id" {
  type        = string
  description = "Entra object ID for SQL Server admin"
}

variable "sql_entra_admin_tenant_id" {
  type        = string
  description = "Entra tenant ID for SQL Server admin; leave null to use current tenant"
  default     = null
}
