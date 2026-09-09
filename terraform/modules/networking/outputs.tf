output "vnet_id" {
  description = "Resource ID of the Virtual Network."
  value       = azurerm_virtual_network.sentinel_vnet.id
}

output "vnet_name" {
  description = "Name of the Virtual Network."
  value       = azurerm_virtual_network.sentinel_vnet.name
}

output "ai_foundry_subnet_id" {
  description = "Subnet ID for AI Foundry resources."
  value       = azurerm_subnet.ai_foundry_subnet.id
}

output "ai_search_subnet_id" {
  description = "Subnet ID for AI Search resources."
  value       = azurerm_subnet.ai_search_subnet.id
}

output "data_subnet_id" {
  description = "Subnet ID for Data & Storage resources."
  value       = azurerm_subnet.data_subnet.id
}

output "nsg_id" {
  description = "Network Security Group ID."
  value       = azurerm_network_security_group.ai_nsg.id
}
