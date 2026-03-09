locals {
  vnet_address_prefix    = "10.1.0.0/22"
  clones_subnet_prefix   = "10.1.1.0/24"
  scanners_subnet_prefix = "10.1.2.0/24"

  environment = var.env == "" ? "" : "-${var.env}"
}

# Public IP for NAT Gateway
resource "azurerm_public_ip" "scanners" {
  count = var.deploy_nat_gateway ? 1 : 0

  name                = "${var.resource_prefix}pip-csscanning-scanners${local.environment}-${var.location}${var.resource_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# NAT Gateway for outbound connectivity
resource "azurerm_nat_gateway" "scanners" {
  count = var.deploy_nat_gateway ? 1 : 0

  name                    = "${var.resource_prefix}ng-csscanning-scanners${local.environment}-${var.location}${var.resource_suffix}"
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  tags                    = var.tags
}

# Associate Public IP with NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "scanners" {
  count = var.deploy_nat_gateway ? 1 : 0

  nat_gateway_id       = azurerm_nat_gateway.scanners[0].id
  public_ip_address_id = azurerm_public_ip.scanners[0].id
}

# Network Security Group
resource "azurerm_network_security_group" "scanning" {
  name                = "${var.resource_prefix}nsg-csscanning${local.environment}-${var.location}${var.resource_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Virtual Network
resource "azurerm_virtual_network" "scanning" {
  name                = "${var.resource_prefix}vnet-csscanning${local.environment}-${var.location}${var.resource_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [local.vnet_address_prefix]

  tags = merge(var.tags, {
    CSTagResourceType = "VirtualNetwork"
  })
}

# Clones Subnet
resource "azurerm_subnet" "clones" {
  name                 = "${var.resource_prefix}snet-csscanning-clones${local.environment}-${var.location}${var.resource_suffix}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.scanning.name
  address_prefixes     = [local.clones_subnet_prefix]
}

# Associate NSG with Clones Subnet
resource "azurerm_subnet_network_security_group_association" "clones" {
  subnet_id                 = azurerm_subnet.clones.id
  network_security_group_id = azurerm_network_security_group.scanning.id
}

# Scanners Subnet
resource "azurerm_subnet" "scanners" {
  name                 = "${var.resource_prefix}snet-csscanning-scanners${local.environment}-${var.location}${var.resource_suffix}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.scanning.name
  address_prefixes     = [local.scanners_subnet_prefix]

  depends_on = [
    azurerm_subnet.clones
  ]
}

# Associate NSG with Scanners Subnet
resource "azurerm_subnet_network_security_group_association" "scanners" {
  subnet_id                 = azurerm_subnet.scanners.id
  network_security_group_id = azurerm_network_security_group.scanning.id
}

# Associate NAT Gateway with Scanners Subnet
resource "azurerm_subnet_nat_gateway_association" "scanners" {
  count = var.deploy_nat_gateway ? 1 : 0

  subnet_id      = azurerm_subnet.scanners.id
  nat_gateway_id = azurerm_nat_gateway.scanners[0].id
}
