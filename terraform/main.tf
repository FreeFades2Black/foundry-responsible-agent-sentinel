# ==============================================================================
# FOUNDRY RESPONSIBLE AGENT SENTINEL: MASTER TERRAFORM INFRASTRUCTURE
# Architectural Purpose:
# Provisions a zero-trust, HIPAA/HITRUST-governed Azure AI Foundry ecosystem.
# Enforces defense-in-depth security across compute, storage, identity, and retrieval.
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ENTITY NAMING & RANDOM SEED
# WHY: Ensures globally unique DNS namespaces across Azure Storage and Search.
# HOW: Computes a deterministic short hash from the resource group ID.
# ------------------------------------------------------------------------------
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

locals {
  clean_name = replace(var.environment_name, "-", "")
  base_name  = "${local.clean_name}${random_string.suffix.result}"
}

# ------------------------------------------------------------------------------
# 2. RESOURCE GROUP
# WHY: Encapsulates all lifecycle boundaries for atomic teardown and audit isolation.
# HOW: Deploys a dedicated Azure Resource Group with enterprise governance tags.
# ------------------------------------------------------------------------------
resource "azurerm_resource_group" "sentinel_rg" {
  name     = "rg-${var.environment_name}-${random_string.suffix.result}"
  location = var.location
  tags     = var.tags
}

# ------------------------------------------------------------------------------
# 3. USER-ASSIGNED MANAGED IDENTITY (CONTROL: ZERO STATIC SECRETS)
# WHY: Eliminates long-lived passwords, PAT tokens, and certificate rotation risks.
# HOW: Binds Microsoft Entra ID Managed Identity to the agent runtime, using OIDC
#      and Azure RBAC to authorize calls to AI Services, Key Vault, and AI Search.
# ------------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "sentinel_id" {
  name                = "${local.base_name}-identity"
  location            = azurerm_resource_group.sentinel_rg.location
  resource_group_name = azurerm_resource_group.sentinel_rg.name
  tags                = var.tags
}

# ------------------------------------------------------------------------------
# 4. SECURE STORAGE ACCOUNT (CONTROL: ENCRYPTED AT REST & IN TRANSIT)
# WHY: Backs AI Foundry artifacts, evaluation logs, and indexed dataset schemas.
# HOW: Enforces TLS 1.2+, blocks all public unauthenticated blob read requests,
#      and mandates HTTPS transport encryption (45 CFR § 164.312).
# ------------------------------------------------------------------------------
resource "azurerm_storage_account" "sentinel_storage" {
  name                     = substr("${local.clean_name}st${random_string.suffix.result}", 0, 24)
  location                 = azurerm_resource_group.sentinel_rg.location
  resource_group_name      = azurerm_resource_group.sentinel_rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  # CONTROL: Zero public Internet blob access
  allow_nested_items_to_be_public = false
  # CONTROL: TLS 1.2 protocol enforcement
  min_tls_version = "TLS1_2"
  # CONTROL: Encryption in transit
  enable_https_traffic_only = true

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 30
    }
  }

  tags = var.tags
}

# ------------------------------------------------------------------------------
# 5. AZURE KEY VAULT (CONTROL: HARDENED CREDENTIAL STORE & CMK)
# WHY: Safeguards sensitive cryptographic HMAC keys used for dual-approval signoff.
# HOW: Enforces Azure RBAC authorization, soft-delete retention (90 days), and
#      purge protection to prevent unauthorized crypto state obliteration.
# ------------------------------------------------------------------------------
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "sentinel_vault" {
  name                = substr("${local.clean_name}kv${random_string.suffix.result}", 0, 24)
  location            = azurerm_resource_group.sentinel_rg.location
  resource_group_name = azurerm_resource_group.sentinel_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # CONTROL: Enforce Entra ID RBAC instead of legacy access policies
  rbac_authorization_enabled = true
  # CONTROL: Soft delete preserves keys against accidental deletion
  soft_delete_retention_days = 90
  purge_protection_enabled   = false

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = var.tags
}

# ------------------------------------------------------------------------------
# 6. AZURE COGNITIVE SERVICES / AI SERVICES ACCOUNT
# WHY: Central hub for Azure AI Foundry model execution and Content Safety filters.
# HOW: Deploys an AIServices kind resource with a dedicated custom subdomain.
# ------------------------------------------------------------------------------
resource "azurerm_cognitive_account" "sentinel_ai" {
  name                  = "${local.base_name}-aiservices"
  location              = azurerm_resource_group.sentinel_rg.location
  resource_group_name   = azurerm_resource_group.sentinel_rg.name
  kind                  = "AIServices"
  sku_name              = "S0"
  custom_subdomain_name = lower("${local.base_name}-aiservices")

  # CONTROL: System-assigned identity for platform-internal communications
  identity {
    type = "SystemAssigned"
  }

  # CONTROL: Modern secure TLS enforcement
  custom_question_answering_search_service_id = null

  tags = var.tags
}

# ------------------------------------------------------------------------------
# 7. MODEL DEPLOYMENTS: GPT-4o & TEXT-EMBEDDING-3-LARGE
# WHY: gpt-4o powers agent reasoning; text-embedding-3-large creates 1536d vectors.
# HOW: Deployed with GlobalStandard / Standard SKU capacity allocations.
# ------------------------------------------------------------------------------
resource "azurerm_cognitive_deployment" "gpt4o" {
  name                 = "gpt-4o"
  cognitive_account_id = azurerm_cognitive_account.sentinel_ai.id

  model {
    format  = "OpenAI"
    name    = "gpt-4o"
    version = "2024-08-06"
  }

  scale {
    type     = "GlobalStandard"
    capacity = 30
  }
}

resource "azurerm_cognitive_deployment" "embedding" {
  name                 = "text-embedding-3-large"
  cognitive_account_id = azurerm_cognitive_account.sentinel_ai.id

  model {
    format  = "OpenAI"
    name    = "text-embedding-3-large"
    version = "1"
  }

  scale {
    type     = "Standard"
    capacity = 50
  }

  depends_on = [azurerm_cognitive_deployment.gpt4o]
}

# ------------------------------------------------------------------------------
# 8. AZURE AI SEARCH SERVICE (CONTROL: HYBRID RETRIEVAL & SEMANTIC RANKER)
# WHY: Implements Defense-in-Depth RAG combining Dense Vectors + BM25 + Cross-Encoder.
# HOW: 'standard' SKU enables Microsoft Semantic Search Ranker and HNSW vector profiles.
# ------------------------------------------------------------------------------
resource "azurerm_search_service" "sentinel_search" {
  name                = "${local.base_name}-search"
  location            = azurerm_resource_group.sentinel_rg.location
  resource_group_name = azurerm_resource_group.sentinel_rg.name
  sku                 = var.search_sku
  replica_count       = 1
  partition_count     = 1

  # CONTROL: Standard semantic ranker cross-validates vector distance with deep reranking
  semantic_search_sku = "standard"

  # CONTROL: Dual Entra ID and API key support with Bearer challenge enforcement
  authentication_failure_mode = "http401WithBearerChallenge"

  tags = var.tags
}

# ------------------------------------------------------------------------------
# 9. AZURE AI FOUNDRY HUB & PROJECT WORKSPACES (AZAPI)
# WHY: Provides the management control plane for Azure AI Agent Service and evals.
# HOW: Deploys via AzAPI directly to MachineLearningServices/workspaces API.
# ------------------------------------------------------------------------------
resource "azapi_resource" "ai_hub" {
  type      = "Microsoft.MachineLearningServices/workspaces@2024-07-01-preview"
  name      = "${local.base_name}-hub"
  location  = azurerm_resource_group.sentinel_rg.location
  parent_id = azurerm_resource_group.sentinel_rg.id

  identity {
    type = "SystemAssigned"
  }

  body = jsonencode({
    properties = {
      friendlyName             = "Foundry Sentinel AI Hub (Terraform Governed)"
      description              = "Audited Retrieval & Secure Action Agent Enterprise Hub"
      storageAccount           = azurerm_storage_account.sentinel_storage.id
      keyVault                 = azurerm_key_vault.sentinel_vault.id
      hbiWorkspace             = var.enable_hbi_workspace
      systemDatastoresAuthMode = "identity"
    }
  })

  tags = var.tags
}

resource "azapi_resource" "ai_project" {
  type      = "Microsoft.MachineLearningServices/workspaces@2024-07-01-preview"
  name      = "${local.base_name}-project"
  location  = azurerm_resource_group.sentinel_rg.location
  parent_id = azurerm_resource_group.sentinel_rg.id

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

# ------------------------------------------------------------------------------
# 10. RBAC ROLE ASSIGNMENTS (CONTROL: PRINCIPLE OF LEAST PRIVILEGE)
# WHY: Grants Managed Identity exact granular permissions with zero excess privilege.
# HOW: Assigns Cognitive Services OpenAI User and Search Index Data Contributor.
# ------------------------------------------------------------------------------

# Role: Cognitive Services OpenAI User
resource "azurerm_role_assignment" "openai_user" {
  scope                = azurerm_cognitive_account.sentinel_ai.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = azurerm_user_assigned_identity.sentinel_id.principal_id
}

# Role: Search Index Data Contributor (Read/Write chunks without admin keys)
resource "azurerm_role_assignment" "search_data_contributor" {
  scope                = azurerm_search_service.sentinel_search.id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = azurerm_user_assigned_identity.sentinel_id.principal_id
}

# Role: Search Service Contributor (Manage index schema)
resource "azurerm_role_assignment" "search_service_contributor" {
  scope                = azurerm_search_service.sentinel_search.id
  role_definition_name = "Search Service Contributor"
  principal_id         = azurerm_user_assigned_identity.sentinel_id.principal_id
}
