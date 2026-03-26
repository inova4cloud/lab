variable "prefix" {
  type        = string
  description = "Name prefix for resources"
  default     = "tfc-lab"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "westus2"
}

variable "rg_name" {
  type        = string
  description = "Resource group name"
  default     = "rg-tfc-lab"
}

variable "vm_count" {
  type    = number
  default = 2
}

variable "vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "admin_ssh_public_key" {
  type        = string
  description = "SSH public key content (e.g. starts with ssh-rsa or ssh-ed25519)"
  sensitive   = true
}

variable "ssh_source_cidr" {
  type        = string
  description = "CIDR allowed to SSH to VMs (lock this down)"
  default     = "0.0.0.0/0"
}
