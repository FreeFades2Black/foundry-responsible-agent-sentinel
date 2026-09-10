variable "resource_group_name" {
  type        = string
  description = "Target Resource Group name for the shared dashboard."
}

variable "location" {
  type        = string
  description = "Azure region for the dashboard resource."
}

variable "dashboard_name" {
  type        = string
  default     = "Sentinel-Foundry-Operations-Dashboard"
  description = "Display name of the shared Azure Portal dashboard."
}

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID for Cost Management and metric scopes."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags applied to the dashboard."
}
