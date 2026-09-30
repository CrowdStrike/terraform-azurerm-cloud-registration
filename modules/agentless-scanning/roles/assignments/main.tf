data "azurerm_client_config" "current" {}

locals {
  subscription_id                     = data.azurerm_client_config.current.subscription_id
  subscription_role_definition_prefix = "/subscriptions/${local.subscription_id}/providers/Microsoft.Authorization/roleDefinitions"
  role_definition_guid_pattern        = "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"

  # Azure returns role definition IDs scoped to the assignment's subscription,
  # regardless of where the role was defined (e.g. management group).
  # Without normalizing to subscription scope, the ForceNew mismatch on
  # role_definition_id causes replacements on every plan.
  definition_ids = {
    subscription_access  = "${local.subscription_role_definition_prefix}/${regex(local.role_definition_guid_pattern, var.role_definition_ids.subscription_access)}"
    rg_access            = var.role_definition_ids.rg_access == "" ? "" : "${local.subscription_role_definition_prefix}/${regex(local.role_definition_guid_pattern, var.role_definition_ids.rg_access)}"
    rg_access_target     = var.role_definition_ids.rg_access_target == "" ? "" : "${local.subscription_role_definition_prefix}/${regex(local.role_definition_guid_pattern, var.role_definition_ids.rg_access_target)}"
    subscription_scanner = var.role_definition_ids.subscription_scanner == "" ? "" : "${local.subscription_role_definition_prefix}/${regex(local.role_definition_guid_pattern, var.role_definition_ids.subscription_scanner)}"
    custom_vnet_subnet   = var.role_definition_ids.custom_vnet_subnet == "" ? "" : "${local.subscription_role_definition_prefix}/${regex(local.role_definition_guid_pattern, var.role_definition_ids.custom_vnet_subnet)}"
    rg_scanner           = var.role_definition_ids.rg_scanner == "" ? "" : "${local.subscription_role_definition_prefix}/${regex(local.role_definition_guid_pattern, var.role_definition_ids.rg_scanner)}"
  }
}

resource "azurerm_role_assignment" "subscription_access" {
  scope              = "/subscriptions/${local.subscription_id}"
  role_definition_id = local.definition_ids.subscription_access
  principal_id       = var.agentless_scanning_principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "rg_access" {
  count = var.is_host || local.definition_ids.rg_access_target != "" ? 1 : 0

  scope              = "/subscriptions/${local.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_id = var.is_host ? local.definition_ids.rg_access : local.definition_ids.rg_access_target
  principal_id       = var.agentless_scanning_principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "subscription_scanner" {
  count = var.enable_dspm ? 1 : 0

  scope              = "/subscriptions/${local.subscription_id}"
  role_definition_id = local.definition_ids.subscription_scanner
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
  role_definition_id = local.definition_ids.rg_scanner
  principal_id       = var.agentless_scanner_identity_principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "custom_vnet_subnet" {
  for_each = var.custom_subnet_ids

  scope              = each.value
  role_definition_id = local.definition_ids.custom_vnet_subnet
  principal_id       = var.agentless_scanning_principal_id
  principal_type     = "ServicePrincipal"
}
