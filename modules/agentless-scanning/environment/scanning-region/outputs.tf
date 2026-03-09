output "vnet_id" {
  description = "Virtual Network ID"
  value       = azurerm_virtual_network.scanning.id
}

output "clones_subnet_id" {
  description = "Clones Subnet ID"
  value       = azurerm_subnet.clones.id
}

output "scanners_subnet_id" {
  description = "Scanners Subnet ID"
  value       = azurerm_subnet.scanners.id
}