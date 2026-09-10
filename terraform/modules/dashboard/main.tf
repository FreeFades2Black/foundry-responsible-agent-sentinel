# ==============================================================================
# MODULE: AZURE PORTAL EXECUTIVE DASHBOARD
# Architectural Purpose:
# Provisions a native shared Azure Portal dashboard showcasing deployed resources,
# real-time compute/storage costs, AI search query performance, and operational health.
# ==============================================================================

resource "azurerm_portal_dashboard" "sentinel_dashboard" {
  name                = var.dashboard_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  dashboard_properties = templatefile("${path.module}/dashboard.json.tpl", {
    subscription_id     = var.subscription_id
    resource_group_name = var.resource_group_name
  })
}
