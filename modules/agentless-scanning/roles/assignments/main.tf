data "azurerm_client_config" "current" {}

locals {
  subscription_id = data.azurerm_client_config.current.subscription_id

  # Role definitions may be created at management-group scope and threaded in
  # as MG-relative IDs. Azure always returns subscription-prefixed IDs when
  # reading back an assignment made at subscription/RG scope, so
  # role_definition_id (ForceNew) must be normalized here or every plan forces
  # a destroy+recreate.
  def_ids = {
    for k, v in var.role_definition_ids :
    k => v == "" ? "" : "/subscriptions/${local.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${regex("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", v)}"
  }
}

resource "azurerm_role_assignment" "subscription_access" {
  scope              = "/subscriptions/${local.subscription_id}"
  role_definition_id = local.def_ids.subscription_access
  principal_id       = var.agentless_scanning_principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "rg_access" {
  count = var.is_host || local.def_ids.rg_access_target != "" ? 1 : 0

  scope              = "/subscriptions/${local.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_id = var.is_host ? local.def_ids.rg_access : local.def_ids.rg_access_target
  principal_id       = var.agentless_scanning_principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "subscription_scanner" {
  count = var.enable_dspm ? 1 : 0

  scope              = "/subscriptions/${local.subscription_id}"
  role_definition_id = local.def_ids.subscription_scanner
  principal_id       = var.agentless_scanner_identity_principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "rg_scanner_reader" {
  scope                = "/subscriptions/${local.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Reader"
  principal_id         = var.agentless_scanner_identity_principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "rg_scanner" {
  count = var.enable_vulnerability_scanning && var.is_host ? 1 : 0

  scope              = "/subscriptions/${local.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_id = local.def_ids.rg_scanner
  principal_id       = var.agentless_scanner_identity_principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "custom_vnet_subnet" {
  for_each = var.custom_subnet_ids

  scope              = each.value
  role_definition_id = local.def_ids.custom_vnet_subnet
  principal_id       = var.agentless_scanning_principal_id
  principal_type     = "ServicePrincipal"
}
