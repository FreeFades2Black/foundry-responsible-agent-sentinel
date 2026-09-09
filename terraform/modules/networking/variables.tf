variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "location" {
  type        = string
  description = "Azure region for network resources."
}

variable "base_name" {
  type        = string
  description = "Base prefix for network entity names."
}

variable "vnet_cidr" {
  type        = string
  description = "CIDR block for the Sentinel Virtual Network."
  default     = "10.0.0.0/16"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags."
  default     = {}
}
