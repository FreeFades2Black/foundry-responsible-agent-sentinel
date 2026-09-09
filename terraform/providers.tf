# ==============================================================================
# TERRAFORM PROVIDERS CONFIGURATION
# Controls & Architecture Rationale:
# 1. Pinned Provider Constraints: Guarantees reproducible infrastructure deployments.
# 2. AzureRM Provider: Manages foundational Azure enterprise resources (Key Vault, Storage, Identity).
# 3. AzAPI Provider: Deploys modern Azure AI Foundry and RAI Content Safety policies
#    directly via Microsoft Azure ARM APIs with zero schema lag.
# ==============================================================================

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.100.0, < 5.0.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">= 1.13.0, < 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azapi" {}

provider "random" {}
