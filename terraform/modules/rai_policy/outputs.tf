output "rai_policy_id" {
  description = "ARM Resource ID of the custom RAI policy."
  value       = azapi_resource.custom_rai_policy.id
}

output "rai_policy_name" {
  description = "Name of the custom RAI policy."
  value       = var.rai_policy_name
}
