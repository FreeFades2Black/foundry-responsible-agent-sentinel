output "search_service_id" {
  description = "Resource ID of the Azure AI Search Service."
  value       = azurerm_search_service.sentinel_search.id
}

output "search_service_name" {
  description = "Name of the Azure AI Search Service."
  value       = azurerm_search_service.sentinel_search.name
}

output "search_endpoint" {
  description = "Endpoint of the Azure AI Search Service."
  value       = "https://${azurerm_search_service.sentinel_search.name}.search.windows.net"
}
