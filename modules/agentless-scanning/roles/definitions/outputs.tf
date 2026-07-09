output "role_definition_ids" {
  description = "Scanning role definition resource IDs."
  value = {
    subscription_access  = azurerm_role_definition.subscription_access.role_definition_resource_id
    rg_access            = length(azurerm_role_definition.rg_access) > 0 ? azurerm_role_definition.rg_access[0].role_definition_resource_id : ""
    rg_access_target     = length(azurerm_role_definition.rg_access_target) > 0 ? azurerm_role_definition.rg_access_target[0].role_definition_resource_id : ""
    subscription_scanner = length(azurerm_role_definition.subscription_scanner) > 0 ? azurerm_role_definition.subscription_scanner[0].role_definition_resource_id : ""
    custom_vnet_subnet   = length(azurerm_role_definition.custom_vnet_subnet) > 0 ? azurerm_role_definition.custom_vnet_subnet[0].role_definition_resource_id : ""
    rg_scanner           = length(azurerm_role_definition.rg_scanner) > 0 ? azurerm_role_definition.rg_scanner[0].role_definition_resource_id : ""
  }
}
