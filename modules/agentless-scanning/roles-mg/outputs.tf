output "role_definition_ids" {
  description = "MG-scoped scanning role definition resource IDs."
  value = {
    subscription_access  = azurerm_role_definition.subscription_access.role_definition_resource_id
    rg_access            = azurerm_role_definition.rg_access.role_definition_resource_id
    subscription_scanner = azurerm_role_definition.subscription_scanner.role_definition_resource_id
    custom_vnet_subnet   = var.use_custom_subnets ? azurerm_role_definition.custom_vnet_subnet[0].role_definition_resource_id : ""
  }
}
