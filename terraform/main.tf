# ==============================================================================
# FOUNDRY RESPONSIBLE AGENT SENTINEL: MASTER TERRAFORM INFRASTRUCTURE
# Architectural Purpose:
# Master orchestrator wiring enterprise networking, zero-trust security & identity,
# Azure AI Foundry Hub, Projects, Model Deployments, AI Search, and RAI Policies.
# ==============================================================================

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

locals {
  clean_name = replace(var.environment_name, "-", "")
  base_name  = "${local.clean_name}${random_string.suffix.result}"
}

data "azurerm_client_config" "current" {}

# 1. Resource Group
resource "azurerm_resource_group" "sentinel_rg" {
  name     = "rg-${var.environment_name}-${random_string.suffix.result}"
  location = var.location
  tags     = var.tags
}

# 2. Module: Networking & Microsegmentation
module "networking" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.sentinel_rg.name
  location            = azurerm_resource_group.sentinel_rg.location
  base_name           = local.base_name
  vnet_cidr           = "10.0.0.0/16"
  tags                = var.tags
}

# 3. Module: Security, Identity & Data Storage (Zero Static Secrets)
module "security_identity" {
  source              = "./modules/security_identity"
  resource_group_name = azurerm_resource_group.sentinel_rg.name
  location            = azurerm_resource_group.sentinel_rg.location
  base_name           = local.base_name
  clean_name          = local.clean_name
  suffix              = random_string.suffix.result
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = var.tags
}

# 4. Module: Azure AI Search & Semantic Ranker
module "ai_search" {
  source              = "./modules/ai_search"
  resource_group_name = azurerm_resource_group.sentinel_rg.name
  location            = azurerm_resource_group.sentinel_rg.location
  base_name           = local.base_name
  sku                 = var.search_sku
  principal_id        = module.security_identity.identity_principal_id
  tags                = var.tags
}

# 5. Module: Azure AI Foundry, Cognitive Services & Model Deployments
module "ai_foundry" {
  source               = "./modules/ai_foundry"
  resource_group_name  = azurerm_resource_group.sentinel_rg.name
  resource_group_id    = azurerm_resource_group.sentinel_rg.id
  location             = azurerm_resource_group.sentinel_rg.location
  base_name            = local.base_name
  storage_account_id   = module.security_identity.storage_account_id
  key_vault_id         = module.security_identity.key_vault_id
  principal_id         = module.security_identity.identity_principal_id
  enable_hbi_workspace = var.enable_hbi_workspace
  tags                 = var.tags
}

# 6. Module: Custom Responsible AI (RAI) Policy & Prompt Shields
module "rai_policy" {
  source                        = "./modules/rai_policy"
  cognitive_account_id          = module.ai_foundry.cognitive_account_id
  rai_policy_name               = var.rai_policy_name
  severity_threshold            = var.rai_severity_threshold
  enable_prompt_shield          = var.enable_prompt_shield
  enable_indirect_attack_filter = var.enable_indirect_attack_filter
}
