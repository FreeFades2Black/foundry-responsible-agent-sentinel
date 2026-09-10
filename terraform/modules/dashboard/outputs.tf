output "dashboard_id" {
  description = "The Resource ID of the provisioned Azure Portal Dashboard."
  value       = azurerm_portal_dashboard.sentinel_dashboard.id
}
