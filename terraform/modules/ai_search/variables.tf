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

variable "sku" {
  type        = string
  description = "Azure AI Search SKU."
  default     = "standard"
}

variable "principal_id" {
  type        = string
  description = "Principal ID of the Managed Identity for RBAC."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags."
  default     = {}
}
