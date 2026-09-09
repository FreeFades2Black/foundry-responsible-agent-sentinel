variable "resource_group_name" {
  type        = string
  description = "Resource Group Name."
}

variable "location" {
  type        = string
  description = "Target Azure Region."
}

variable "base_name" {
  type        = string
  description = "Base naming prefix."
}

variable "clean_name" {
  type        = string
  description = "Alphanumeric cleaned naming string."
}

variable "suffix" {
  type        = string
  description = "Random unique suffix."
}

variable "tenant_id" {
  type        = string
  description = "Azure Entra ID Tenant ID."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags."
  default     = {}
}
