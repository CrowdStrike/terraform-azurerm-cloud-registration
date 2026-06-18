locals {
  scope = var.scope_type == "mg" ? "/providers/Microsoft.Management/managementGroups/${var.scope_id}" : "/subscriptions/${var.scope_id}"

  subscription_access_actions = concat(
    var.role_actions.subscription_access_actions,
    var.input_enable_vulnerability_scanning ? var.role_actions.vulnerability_scanning_subscription_actions : []
  )

  rg_access_actions = concat(
    var.role_actions.host_rg_access_actions,
    !var.agentless_scanning_deploy_nat_gateway ? var.role_actions.conditional_public_ip_actions : [],
    var.input_enable_vulnerability_scanning ? var.role_actions.vulnerability_scanning_rg_actions : []
  )
}

resource "azurerm_role_definition" "subscription_access" {
  name        = "${var.resource_prefix}role-csscanning-access-${var.scope_id}${var.resource_suffix}"
  scope       = local.scope
  description = "CrowdStrike Agentless Scanning Subscription Access Role"

  permissions {
    actions     = local.subscription_access_actions
    not_actions = []
  }

  assignable_scopes = [local.scope]
}

resource "azurerm_role_definition" "rg_access" {
  count = var.is_host || var.scope_type == "mg" ? 1 : 0

  name        = "${var.resource_prefix}role-csscanning-rgaccess-${var.scope_id}${var.resource_suffix}"
  scope       = local.scope
  description = "CrowdStrike Scanning Resource Group Access Role"

  permissions {
    actions     = local.rg_access_actions
    not_actions = []
  }

  assignable_scopes = [local.scope]
}

resource "azurerm_role_definition" "rg_access_target" {
  count = !var.is_host || var.scope_type == "mg" ? 1 : 0

  name        = "${var.resource_prefix}role-csscanning-rgaccess-target-${var.scope_id}${var.resource_suffix}"
  scope       = local.scope
  description = "CrowdStrike Scanning Target Resource Group Access Role"

  permissions {
    actions     = var.role_actions.target_rg_access_actions
    not_actions = []
  }

  assignable_scopes = [local.scope]
}

resource "azurerm_role_definition" "subscription_scanner" {
  name        = "${var.resource_prefix}role-csscanning-scanner-${var.scope_id}${var.resource_suffix}"
  scope       = local.scope
  description = "CrowdStrike Agentless Scanning Subscription Scanner Role"

  permissions {
    actions          = var.role_actions.subscription_scanner_actions
    not_actions      = []
    data_actions     = var.role_actions.subscription_scanner_data_actions
    not_data_actions = []
  }

  assignable_scopes = [local.scope]
}

resource "azurerm_role_definition" "custom_vnet_subnet" {
  count = var.use_custom_subnets ? 1 : 0

  name        = "${var.resource_prefix}role-csscanning-custom-vnet-${var.scope_id}${var.resource_suffix}"
  scope       = local.scope
  description = "CrowdStrike Scanning Custom VNet Subnet Role"

  permissions {
    actions     = var.role_actions.custom_vnet_subnet_actions
    not_actions = []
  }

  assignable_scopes = [local.scope]
}

resource "azurerm_role_definition" "rg_scanner" {
  count = var.input_enable_vulnerability_scanning && (var.is_host || var.scope_type == "mg") ? 1 : 0

  name        = "${var.resource_prefix}role-csscanning-rg-scanner-${var.scope_id}${var.resource_suffix}"
  scope       = local.scope
  description = "CrowdStrike Agentless Scanning Scanner Resource Group Role"

  permissions {
    actions     = var.role_actions.rg_scanner_actions
    not_actions = []
  }

  assignable_scopes = [local.scope]
}
