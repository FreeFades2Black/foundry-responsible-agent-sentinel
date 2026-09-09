# ==============================================================================
# MODULE: SECURITY, IDENTITY & DATA STORAGE
# Architecture Rationale:
# Enforces zero-trust identity (Managed Identity), cryptographic key retention
# (Key Vault), and HIPAA-compliant data storage (Storage Account).
# ==============================================================================

# User-Assigned Managed Identity: Passwordless Zero-Trust Operations
resource "azurerm_user_assigned_identity" "sentinel_id" {
  name                = "${var.base_name}-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Key Vault: Cryptographic Signoff HMAC Keys & Customer Managed Key (CMK) Store
resource "azurerm_key_vault" "sentinel_vault" {
  name                       = substr("${var.clean_name}kv${var.suffix}", 0, 24)
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  soft_delete_retention_days = 90
  purge_protection_enabled   = false

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = var.tags
}

# Storage Account: AI Foundry Metadata & Workspace Store
resource "azurerm_storage_account" "sentinel_storage" {
  name                     = substr("${var.clean_name}st${var.suffix}", 0, 24)
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"
  # CONTROL: HTTPS traffic only enforced natively in Azure Storage
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 30
    }
  }

  tags = var.tags
}
