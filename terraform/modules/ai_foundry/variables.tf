variable "resource_group_name" {
  type        = string
  description = "Resource Group Name."
}

variable "resource_group_id" {
  type        = string
  description = "Resource Group ARM Resource ID."
}

variable "location" {
  type        = string
  description = "Target Azure Region."
}

variable "base_name" {
  type        = string
  description = "Base naming prefix."
}

variable "storage_account_id" {
  type        = string
  description = "Storage Account ID for AI Foundry."
}

variable "key_vault_id" {
  type        = string
  description = "Key Vault ID for AI Foundry."
}

variable "principal_id" {
  type        = string
  description = "Principal ID of the Managed Identity for RBAC."
}

variable "gpt4o_capacity" {
  type        = number
  description = "TPM capacity for gpt-4o."
  default     = 30
}

variable "embedding_capacity" {
  type        = number
  description = "TPM capacity for text-embedding-3-large."
  default     = 50
}

variable "enable_hbi_workspace" {
  type        = bool
  description = "Enable High Business Impact encryption."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Resource tags."
  default     = {}
}
