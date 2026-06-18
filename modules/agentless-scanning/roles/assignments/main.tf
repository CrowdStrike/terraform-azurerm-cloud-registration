data "azurerm_client_config" "current" {}

locals {
  subscription_id = data.azurerm_client_config.current.subscription_id
}

resource "azurerm_role_assignment" "subscription_access" {
  scope              = "/subscriptions/${local.subscription_id}"
  role_definition_id = var.role_definition_ids.subscription_access
  principal_id       = var.agentless_scanning_principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "rg_access" {
  scope              = "/subscriptions/${local.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_id = var.is_host ? var.role_definition_ids.rg_access : var.role_definition_ids.rg_access_target
  principal_id       = var.agentless_scanning_principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "subscription_scanner" {
  scope              = "/subscriptions/${local.subscription_id}"
  role_definition_id = var.role_definition_ids.subscription_scanner
  principal_id       = var.agentless_scanner_identity_principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "rg_scanner" {
  scope                = "/subscriptions/${local.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Reader"
  principal_id         = var.agentless_scanner_identity_principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "rg_scanner_vuln" {
  count = var.input_enable_vulnerability_scanning ? 1 : 0

  scope              = "/subscriptions/${local.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_id = var.role_definition_ids.rg_scanner
  principal_id       = var.agentless_scanner_identity_principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "custom_vnet_subnet" {
  for_each = var.custom_subnet_ids

  scope              = each.value
  role_definition_id = var.role_definition_ids.custom_vnet_subnet
  principal_id       = var.agentless_scanning_principal_id
  principal_type     = "ServicePrincipal"
}
