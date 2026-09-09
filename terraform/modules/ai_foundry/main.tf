# ==============================================================================
# MODULE: AZURE AI FOUNDRY, COGNITIVE SERVICES & MODEL DEPLOYMENTS
# Architecture Rationale:
# Deploys the AI Services Account, GPT-4o & Embedding model deployments,
# AI Foundry Hub and Project workspaces, and links RBAC credentials.
# ==============================================================================

resource "azurerm_cognitive_account" "sentinel_ai" {
  name                  = "${var.base_name}-aiservices"
  location              = var.location
  resource_group_name   = var.resource_group_name
  kind                  = "AIServices"
  sku_name              = "S0"
  custom_subdomain_name = lower("${var.base_name}-aiservices")

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Model Deployment 1: gpt-4o for Sentinel Reasoning & Agent Execution
resource "azurerm_cognitive_deployment" "gpt4o" {
  name                 = "gpt-4o"
  cognitive_account_id = azurerm_cognitive_account.sentinel_ai.id

  model {
    format  = "OpenAI"
    name    = "gpt-4o"
    version = "2024-08-06"
  }

  sku {
    name     = "GlobalStandard"
    capacity = var.gpt4o_capacity
  }
}

# Model Deployment 2: text-embedding-3-large for 1536d Vector Embeddings
resource "azurerm_cognitive_deployment" "embedding" {
  name                 = "text-embedding-3-large"
  cognitive_account_id = azurerm_cognitive_account.sentinel_ai.id

  model {
    format  = "OpenAI"
    name    = "text-embedding-3-large"
    version = "1"
  }

  sku {
    name     = "Standard"
    capacity = var.embedding_capacity
  }

  depends_on = [azurerm_cognitive_deployment.gpt4o]
}

# AI Foundry Hub (MachineLearningServices/workspaces kind Hub)
resource "azapi_resource" "ai_hub" {
  type      = "Microsoft.MachineLearningServices/workspaces@2024-07-01-preview"
  name      = "${var.base_name}-hub"
  location  = var.location
  parent_id = var.resource_group_id

  identity {
    type = "SystemAssigned"
  }

  body = jsonencode({
    properties = {
      friendlyName             = "Foundry Sentinel AI Hub"
      description              = "Enterprise Hub for Audited Retrieval & Secure Action Agent"
      storageAccount           = var.storage_account_id
      keyVault                 = var.key_vault_id
      hbiWorkspace             = var.enable_hbi_workspace
      systemDatastoresAuthMode = "identity"
    }
  })

  tags = var.tags
}

# AI Foundry Project
resource "azapi_resource" "ai_project" {
  type      = "Microsoft.MachineLearningServices/workspaces@2024-07-01-preview"
  name      = "${var.base_name}-project"
  location  = var.location
  parent_id = var.resource_group_id

  identity {
    type = "SystemAssigned"
  }

  body = jsonencode({
    properties = {
      friendlyName  = "Gilead Sentinel RAI Project"
      description   = "Enterprise Project with evaluated agents and Content Safety binding"
      hubResourceId = azapi_resource.ai_hub.id
    }
  })

  tags = var.tags
}

# Role: Cognitive Services OpenAI User
resource "azurerm_role_assignment" "openai_user" {
  scope                = azurerm_cognitive_account.sentinel_ai.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = var.principal_id
}
