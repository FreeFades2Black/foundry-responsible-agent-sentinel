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
  }
}
