output "cognitive_account_id" {
  description = "Resource ID of the Cognitive Services Account."
  value       = azurerm_cognitive_account.sentinel_ai.id
}

output "cognitive_account_name" {
  description = "Name of the Cognitive Services Account."
  value       = azurerm_cognitive_account.sentinel_ai.name
}

output "cognitive_account_endpoint" {
  description = "Endpoint of the Cognitive Services Account."
  value       = azurerm_cognitive_account.sentinel_ai.endpoint
}

output "hub_id" {
  description = "Resource ID of the Azure AI Foundry Hub."
  value       = azapi_resource.ai_hub.id
}

output "project_id" {
  description = "Resource ID of the Azure AI Foundry Project."
  value       = azapi_resource.ai_project.id
}

output "project_name" {
  description = "Name of the Azure AI Foundry Project."
  value       = azapi_resource.ai_project.name
}
