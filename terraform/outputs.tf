# ==============================================================================
# MASTER TERRAFORM OUTPUT DEFINITIONS
# Exports connection strings, resource IDs, and endpoints from underlying modules
# for runtime application configuration and automated CI/CD pipeline execution.
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
  value       = module.security_identity.identity_client_id
}

output "managed_identity_principal_id" {
  description = "Principal ID of the User-Assigned Managed Identity used for RBAC assignments."
  value       = module.security_identity.identity_principal_id
}

output "azure_ai_services_endpoint" {
  description = "HTTPS endpoint of the Azure Cognitive / AI Services account."
  value       = module.ai_foundry.cognitive_account_endpoint
}

output "azure_ai_services_name" {
  description = "Resource name of the Azure Cognitive Services account."
  value       = module.ai_foundry.cognitive_account_name
}

output "azure_search_endpoint" {
  description = "Target Azure AI Search endpoint supporting hybrid vector search and semantic ranker."
  value       = module.ai_search.search_endpoint
}

output "azure_search_service_name" {
  description = "Resource name of the Azure AI Search service."
  value       = module.ai_search.search_service_name
}

output "rai_policy_id" {
  description = "Fully-qualified ARM Resource ID of the custom Responsible AI Content Safety policy."
  value       = module.rai_policy.rai_policy_id
}

output "rai_policy_name" {
  description = "Name of the custom RAI policy attached to model invocations."
  value       = module.rai_policy.rai_policy_name
}

output "azure_ai_foundry_connection_string" {
  description = "Connection string used by azure-ai-projects SDK to bind the agent to Foundry."
  value       = "${azurerm_resource_group.sentinel_rg.location}.api.azureml.ms;${data.azurerm_client_config.current.subscription_id};${azurerm_resource_group.sentinel_rg.name};${module.ai_foundry.project_name}"
}

output "vnet_id" {
  description = "Resource ID of the Sentinel Virtual Network."
  value       = module.networking.vnet_id
}

output "azure_portal_dashboard_id" {
  description = "Resource ID of the provisioned Azure Portal Dashboard for operational monitoring."
  value       = module.dashboard.dashboard_id
}

