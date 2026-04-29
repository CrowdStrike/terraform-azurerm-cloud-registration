locals {
  mg_scope = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
}

# Custom role for subscription-level scanning access (MG-scoped)
resource "azurerm_role_definition" "subscription_access" {
  name        = "${var.resource_prefix}role-csscanning-access-${var.management_group_id}${var.resource_suffix}"
  scope       = local.mg_scope
  description = "CrowdStrike Agentless Scanning Subscription Access Role"

  permissions {
    actions     = var.role_actions.subscription_access_actions
    not_actions = []
  }

  assignable_scopes = [local.mg_scope]
}

# Custom role for resource group level operations (MG-scoped)
resource "azurerm_role_definition" "rg_access" {
  name        = "${var.resource_prefix}role-csscanning-rgaccess-${var.management_group_id}${var.resource_suffix}"
  scope       = local.mg_scope
  description = "CrowdStrike Scanning Resource Group Access Role"

  permissions {
    actions = concat(
      var.role_actions.host_rg_access_actions,
      !var.agentless_scanning_deploy_nat_gateway ? var.role_actions.conditional_public_ip_actions : []
    )
    not_actions = []
  }

  assignable_scopes = [local.mg_scope]
}

# Custom role for target subscription resource group level operations (MG-scoped)
resource "azurerm_role_definition" "rg_access_target" {
  name        = "${var.resource_prefix}role-csscanning-rgaccess-target-${var.management_group_id}${var.resource_suffix}"
  scope       = local.mg_scope
  description = "CrowdStrike Scanning Target Resource Group Access Role"

  permissions {
    actions     = var.role_actions.target_rg_access_actions
    not_actions = []
  }

  assignable_scopes = [local.mg_scope]
}

# Custom role for scanning operations (MG-scoped)
resource "azurerm_role_definition" "subscription_scanner" {
  name        = "${var.resource_prefix}role-csscanning-scanner-${var.management_group_id}${var.resource_suffix}"
  scope       = local.mg_scope
  description = "CrowdStrike Agentless Scanning Subscription Scanner Role"

  permissions {
    actions          = var.role_actions.subscription_scanner_actions
    not_actions      = []
    data_actions     = var.role_actions.subscription_scanner_data_actions
    not_data_actions = []
  }

  assignable_scopes = [local.mg_scope]
}

# Custom role for custom VNet subnet access (MG-scoped)
resource "azurerm_role_definition" "custom_vnet_subnet" {
  count = var.use_custom_subnets ? 1 : 0

  name        = "${var.resource_prefix}role-csscanning-custom-vnet-${var.management_group_id}${var.resource_suffix}"
  scope       = local.mg_scope
  description = "CrowdStrike Scanning Custom VNet Subnet Role"

  permissions {
    actions     = var.role_actions.custom_vnet_subnet_actions
    not_actions = []
  }

  assignable_scopes = [local.mg_scope]
}
