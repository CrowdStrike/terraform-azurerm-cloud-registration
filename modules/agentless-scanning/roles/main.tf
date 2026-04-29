locals {
  subscription_id    = data.azurerm_client_config.current.subscription_id
  use_external_roles = var.external_role_definition_ids != null

  # Only deploy custom subnet roles for host subscription with non-empty map
  use_custom_subnets = length(var.agentless_scanning_custom_vnet_configuration) > 0 && var.agentless_scanning_host_subscription_id == ""

  # Collect all unique subnet IDs from the custom vnet configuration
  custom_subnet_ids = local.use_custom_subnets ? toset(flatten([
    for region, config in var.agentless_scanning_custom_vnet_configuration : [
      config.scanners_subnet_id,
      config.clones_subnet_id,
    ]
  ])) : toset([])
}

data "azurerm_client_config" "current" {}

# Custom role for subscription-level scanning access
resource "azurerm_role_definition" "subscription_access" {
  count = local.use_external_roles ? 0 : 1

  name        = "${var.resource_prefix}role-csscanning-access-${local.subscription_id}${var.resource_suffix}"
  scope       = "/subscriptions/${local.subscription_id}"
  description = "CrowdStrike Agentless Scanning Subscription Access Role"

  permissions {
    actions     = var.role_actions.subscription_access_actions
    not_actions = []
  }

  assignable_scopes = [
    "/subscriptions/${local.subscription_id}"
  ]
}

# Role assignment for subscription access
resource "azurerm_role_assignment" "subscription_access" {
  scope              = "/subscriptions/${local.subscription_id}"
  role_definition_id = local.use_external_roles ? var.external_role_definition_ids.subscription_access : azurerm_role_definition.subscription_access[0].role_definition_resource_id
  principal_id       = var.agentless_scanning_principal_id
  principal_type     = "ServicePrincipal"
}

# Custom role for resource group level operations
resource "azurerm_role_definition" "rg_access" {
  count = local.use_external_roles ? 0 : 1

  name        = "${var.resource_prefix}role-csscanning-rgaccess-${local.subscription_id}${var.resource_suffix}"
  scope       = "/subscriptions/${local.subscription_id}/resourceGroups/${var.resource_group_name}"
  description = "CrowdStrike Scanning Resource Group Access Role"

  permissions {
    actions = var.agentless_scanning_host_subscription_id == "" ? concat(
      var.role_actions.host_rg_access_actions,
      !var.agentless_scanning_deploy_nat_gateway ? var.role_actions.conditional_public_ip_actions : []
    ) : var.role_actions.target_rg_access_actions
    not_actions = []
  }

  assignable_scopes = [
    "/subscriptions/${local.subscription_id}/resourceGroups/${var.resource_group_name}"
  ]
}

# Role assignment for resource group access
resource "azurerm_role_assignment" "rg_access" {
  scope              = "/subscriptions/${local.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_id = local.use_external_roles ? (var.agentless_scanning_host_subscription_id == "" ? var.external_role_definition_ids.rg_access : var.external_role_definition_ids.rg_access_target) : azurerm_role_definition.rg_access[0].role_definition_resource_id
  principal_id       = var.agentless_scanning_principal_id
  principal_type     = "ServicePrincipal"
}

# Custom role for scanning operations
resource "azurerm_role_definition" "subscription_scanner" {
  count = local.use_external_roles ? 0 : 1

  name        = "${var.resource_prefix}role-csscanning-scanner-${local.subscription_id}${var.resource_suffix}"
  scope       = "/subscriptions/${local.subscription_id}"
  description = "CrowdStrike Agentless Scanning Subscription Scanner Role"

  permissions {
    actions          = var.role_actions.subscription_scanner_actions
    not_actions      = []
    data_actions     = var.role_actions.subscription_scanner_data_actions
    not_data_actions = []
  }

  assignable_scopes = [
    "/subscriptions/${local.subscription_id}"
  ]
}

# Scanner role assignment for managed identity
resource "azurerm_role_assignment" "subscription_scanner" {
  scope              = "/subscriptions/${local.subscription_id}"
  role_definition_id = local.use_external_roles ? var.external_role_definition_ids.subscription_scanner : azurerm_role_definition.subscription_scanner[0].role_definition_resource_id
  principal_id       = var.agentless_scanner_identity_principal_id
  principal_type     = "ServicePrincipal"
}

# Built-in Reader role assignment for managed identity
resource "azurerm_role_assignment" "rg_scanner" {
  scope                = "/subscriptions/${local.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Reader"
  principal_id         = var.agentless_scanner_identity_principal_id
  principal_type       = "ServicePrincipal"
}

# Custom role for custom VNet subnet access
resource "azurerm_role_definition" "custom_vnet_subnet" {
  count = !local.use_external_roles && local.use_custom_subnets ? 1 : 0

  name        = "${var.resource_prefix}role-csscanning-custom-vnet-${local.subscription_id}${var.resource_suffix}"
  scope       = "/subscriptions/${local.subscription_id}"
  description = "CrowdStrike Scanning Custom VNet Subnet Role"

  permissions {
    actions     = var.role_actions.custom_vnet_subnet_actions
    not_actions = []
  }

  assignable_scopes = local.custom_subnet_ids
}

# Role assignment for custom VNet subnet access - one per subnet
resource "azurerm_role_assignment" "custom_vnet_subnet" {
  for_each = local.custom_subnet_ids

  scope              = each.value
  role_definition_id = local.use_external_roles ? var.external_role_definition_ids.custom_vnet_subnet : azurerm_role_definition.custom_vnet_subnet[0].role_definition_resource_id
  principal_id       = var.agentless_scanning_principal_id
  principal_type     = "ServicePrincipal"
}
