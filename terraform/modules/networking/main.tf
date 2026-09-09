# ==============================================================================
# MODULE: NETWORKING & BOUNDARY MICROSEGMENTATION
# Architecture Rationale:
# Enforces network-level isolation for Azure AI Foundry, Cognitive Services,
# Storage, and AI Search within a private Virtual Network (VNet).
# ==============================================================================

resource "azurerm_virtual_network" "sentinel_vnet" {
  name                = "${var.base_name}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_cidr]
  tags                = var.tags
}

# Subnet 1: AI Foundry & Cognitive Services Private Endpoints
resource "azurerm_subnet" "ai_foundry_subnet" {
  name                 = "snet-ai-foundry"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.sentinel_vnet.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 1)] # 10.0.1.0/24
}

# Subnet 2: Azure AI Search Private Endpoints
resource "azurerm_subnet" "ai_search_subnet" {
  name                 = "snet-ai-search"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.sentinel_vnet.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 2)] # 10.0.2.0/24
}

# Subnet 3: Core Data & Vault (Storage Account & Key Vault)
resource "azurerm_subnet" "data_subnet" {
  name                 = "snet-data"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.sentinel_vnet.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 3)] # 10.0.3.0/24
}

# Network Security Group: Microsegmentation
resource "azurerm_network_security_group" "ai_nsg" {
  name                = "${var.base_name}-ai-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # CONTROL: Allow HTTPS inbound only from internal VNet
  security_rule {
    name                       = "AllowVNetInboundHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  # CONTROL: Deny all unauthenticated public internet inbound
  security_rule {
    name                       = "DenyInternetInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "foundry_nsg_assoc" {
  subnet_id                 = azurerm_subnet.ai_foundry_subnet.id
  network_security_group_id = azurerm_network_security_group.ai_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "search_nsg_assoc" {
  subnet_id                 = azurerm_subnet.ai_search_subnet.id
  network_security_group_id = azurerm_network_security_group.ai_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "data_nsg_assoc" {
  subnet_id                 = azurerm_subnet.data_subnet.id
  network_security_group_id = azurerm_network_security_group.ai_nsg.id
}
