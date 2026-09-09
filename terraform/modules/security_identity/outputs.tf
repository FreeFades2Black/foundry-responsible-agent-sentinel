output "identity_id" {
  description = "Resource ID of the User Assigned Identity."
  value       = azurerm_user_assigned_identity.sentinel_id.id
}

output "identity_client_id" {
  description = "Client ID of the User Assigned Identity."
  value       = azurerm_user_assigned_identity.sentinel_id.client_id
}

output "identity_principal_id" {
  description = "Principal ID of the User Assigned Identity."
  value       = azurerm_user_assigned_identity.sentinel_id.principal_id
}

output "key_vault_id" {
  description = "Key Vault Resource ID."
  value       = azurerm_key_vault.sentinel_vault.id
}

output "key_vault_uri" {
  description = "Key Vault Vault URI."
  value       = azurerm_key_vault.sentinel_vault.vault_uri
}

output "storage_account_id" {
  description = "Storage Account Resource ID."
  value       = azurerm_storage_account.sentinel_storage.id
}

output "storage_account_name" {
  description = "Storage Account Name."
  value       = azurerm_storage_account.sentinel_storage.name
}
