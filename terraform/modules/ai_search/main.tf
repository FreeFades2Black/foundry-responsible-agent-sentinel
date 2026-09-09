# ==============================================================================
# MODULE: AZURE AI SEARCH & SEMANTIC RANKER
# Architecture Rationale:
# Provides hybrid search infrastructure: Dense Vector (HNSW) + Lexical (BM25)
# + Microsoft Cross-Encoder Semantic Ranker with Entra ID security filtering.
# ==============================================================================

resource "azurerm_search_service" "sentinel_search" {
  name                = "${var.base_name}-search"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  replica_count       = 1
  partition_count     = 1

  semantic_search_sku         = "standard"
  authentication_failure_mode = "http401WithBearerChallenge"

  tags = var.tags
}

# Role: Search Index Data Contributor
resource "azurerm_role_assignment" "search_data_contributor" {
  scope                = azurerm_search_service.sentinel_search.id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = var.principal_id
}

# Role: Search Service Contributor
resource "azurerm_role_assignment" "search_service_contributor" {
  scope                = azurerm_search_service.sentinel_search.id
  role_definition_name = "Search Service Contributor"
  principal_id         = var.principal_id
}
