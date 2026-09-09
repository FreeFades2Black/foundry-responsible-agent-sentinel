# ==============================================================================
# TERRAFORM OUTPUT DEFINITIONS
# Exports connection strings, resource IDs, and endpoints required for application
# runtime configuration and automated CI/CD pipeline execution.
# ==============================================================================

output "resource_group_name" {
  description = "Name of the provisioned Azure Resource Group."
  value       = azurerm_resource_group.sentinel_rg.name
}

output "azure_subscription_id" {
  description = "Target Azure Subscription ID hosting Sentinel resources."
  value       = data.azurerm_client_config.current.subscription_id
}

output "managed_identity_client_id" {
  description = "Client ID of the User-Assigned Managed Identity used for passwordless auth."
  value       = azurerm_user_assigned_identity.sentinel_id.client_id
}

output "managed_identity_principal_id" {
  description = "Principal ID of the User-Assigned Managed Identity used for RBAC assignments."
  value       = azurerm_user_assigned_identity.sentinel_id.principal_id
}

output "azure_ai_services_endpoint" {
  description = "HTTPS endpoint of the Azure Cognitive / AI Services account."
  value       = azurerm_cognitive_account.sentinel_ai.endpoint
}

output "azure_ai_services_name" {
  description = "Resource name of the Azure Cognitive Services account."
  value       = azurerm_cognitive_account.sentinel_ai.name
}

output "azure_search_endpoint" {
  description = "Target Azure AI Search endpoint supporting hybrid vector search and semantic ranker."
  value       = "https://${azurerm_search_service.sentinel_search.name}.search.windows.net"
}

output "azure_search_service_name" {
  description = "Resource name of the Azure AI Search service."
  value       = azurerm_search_service.sentinel_search.name
}

output "rai_policy_id" {
  description = "Fully-qualified ARM Resource ID of the custom Responsible AI Content Safety policy."
  value       = azapi_resource.custom_rai_policy.id
}

output "rai_policy_name" {
  description = "Name of the custom RAI policy attached to model invocations."
  value       = var.rai_policy_name
}

output "azure_ai_foundry_connection_string" {
  description = "Connection string used by azure-ai-projects SDK to bind the agent to Foundry."
  value       = "${azurerm_resource_group.sentinel_rg.location}.api.azureml.ms;${data.azurerm_client_config.current.subscription_id};${azurerm_resource_group.sentinel_rg.name};${azapi_resource.ai_project.name}"
}
