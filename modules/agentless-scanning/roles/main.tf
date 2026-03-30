locals {
  subscription_id    = data.azurerm_client_config.current.subscription_id
  # Only deploy custom subnet roles for host subscription with non-empty map
  use_custom_subnets = length(var.agentless_scanning_custom_vnet_configuration) > 0 && var.agentless_scanning_host_subscription_id == ""

  # Collect all unique subnet IDs from the custom vnet configuration
  custom_subnet_ids = local.use_custom_subnets ? toset(flatten([
    for region, config in var.agentless_scanning_custom_vnet_configuration : [
      config.scanners_subnet_id,
      config.clones_subnet_id,
    ]
  ])) : toset([])

  host_rg_access_actions = [
    # ============ Blob Storage ============
    "Microsoft.Network/privateEndpoints/read",
    "Microsoft.Network/privateEndpoints/write",
    "Microsoft.Network/privateEndpoints/delete",
    "Microsoft.Network/virtualNetworks/subnets/join/action",
    # ============ Scanner VM ============
    "Microsoft.Network/networkSecurityGroups/read",
    "Microsoft.Network/networkSecurityGroups/write",
    "Microsoft.Network/networkSecurityGroups/delete",
    "Microsoft.Network/networkInterfaces/read",
    "Microsoft.Network/networkInterfaces/write",
    "Microsoft.Network/networkInterfaces/delete",
    "Microsoft.Network/networkInterfaces/join/action",
    "Microsoft.Compute/virtualMachines/read",
    "Microsoft.Compute/virtualMachines/write",
    "Microsoft.Compute/virtualMachines/delete",
    "Microsoft.Network/virtualNetworks/read",
    "Microsoft.ManagedIdentity/userAssignedIdentities/read",
    "Microsoft.ManagedIdentity/userAssignedIdentities/assign/action",
    "Microsoft.Resources/deployments/read",
    "Microsoft.Resources/deployments/write",
    "Microsoft.Resources/deployments/delete",
    "Microsoft.Resources/deployments/operationStatuses/read",
    "Microsoft.Resources/deploymentStacks/*",
    "Microsoft.Network/publicIPAddresses/delete",
    # ============ Validation ============
    "Microsoft.Network/virtualNetworks/subnets/read",
    "Microsoft.Resources/deployments/whatIf/action",
    "Microsoft.Resources/deployments/validate/action",
    "Microsoft.Resources/deploymentScripts/read",
    "Microsoft.KeyVault/vaults/read",
    "Microsoft.Compute/virtualMachines/retrieveBootDiagnosticsData/action",
  ]
  target_rg_access_actions = []

  conditional_public_ip_actions = [
    "Microsoft.Network/publicIPAddresses/read",
    "Microsoft.Network/publicIPAddresses/write",
    "Microsoft.Network/publicIPAddresses/join/action"
  ]
}

data "azurerm_client_config" "current" {}

# Custom role for subscription-level scanning access
resource "azurerm_role_definition" "subscription_access" {
  name        = "${var.resource_prefix}role-csscanning-access-${local.subscription_id}${var.resource_suffix}"
  scope       = "/subscriptions/${local.subscription_id}"
  description = "CrowdStrike Agentless Scanning Subscription Access Role"

  permissions {
    actions = [
      # ============ Blob Storage ============
      "Microsoft.Storage/storageAccounts/read",
      "Microsoft.Storage/storageAccounts/PrivateEndpointConnectionsApproval/action",
      # ============ Validation ============
      "Microsoft.Authorization/roleAssignments/read",
      "Microsoft.Authorization/policyDefinitions/read",
    ]
    not_actions = []
  }

  assignable_scopes = [
    "/subscriptions/${local.subscription_id}"
  ]
}

# Role assignment for subscription access
resource "azurerm_role_assignment" "subscription_access" {
  scope              = "/subscriptions/${local.subscription_id}"
  role_definition_id = azurerm_role_definition.subscription_access.role_definition_resource_id
  principal_id       = var.agentless_scanning_principal_id
  principal_type     = "ServicePrincipal"
}

# Custom role for resource group level operations
resource "azurerm_role_definition" "rg_access" {
  name        = "${var.resource_prefix}role-csscanning-rgaccess-${local.subscription_id}${var.resource_suffix}"
  scope       = "/subscriptions/${local.subscription_id}/resourceGroups/${var.resource_group_name}"
  description = "CrowdStrike Scanning Resource Group Access Role"

  permissions {
    actions = var.agentless_scanning_host_subscription_id == "" ? concat(
      local.host_rg_access_actions,
      !var.agentless_scanning_deploy_nat_gateway ? local.conditional_public_ip_actions : []
    ) : local.target_rg_access_actions
    not_actions = []
  }

  assignable_scopes = [
    "/subscriptions/${local.subscription_id}/resourceGroups/${var.resource_group_name}"
  ]
}

# Role assignment for resource group access
resource "azurerm_role_assignment" "rg_access" {
  scope              = "/subscriptions/${local.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_id = azurerm_role_definition.rg_access.role_definition_resource_id
  principal_id       = var.agentless_scanning_principal_id
  principal_type     = "ServicePrincipal"
}

# Custom role for scanning operations
resource "azurerm_role_definition" "subscription_scanner" {
  name        = "${var.resource_prefix}role-csscanning-scanner-${local.subscription_id}${var.resource_suffix}"
  scope       = "/subscriptions/${local.subscription_id}"
  description = "CrowdStrike Agentless Scanning Subscription Scanner Role"

  permissions {
    actions = [
      "Microsoft.Storage/storageAccounts/blobServices/containers/read",
    ]
    not_actions = []
    data_actions = [
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
    ]
    not_data_actions = []
  }

  assignable_scopes = [
    "/subscriptions/${local.subscription_id}"
  ]
}

# Scanner role assignment for managed identity
resource "azurerm_role_assignment" "subscription_scanner" {
  scope              = "/subscriptions/${local.subscription_id}"
  role_definition_id = azurerm_role_definition.subscription_scanner.role_definition_resource_id
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
  count = local.use_custom_subnets ? 1 : 0

  name        = "${var.resource_prefix}role-csscanning-custom-vnet-${local.subscription_id}${var.resource_suffix}"
  scope       = "/subscriptions/${local.subscription_id}"
  description = "CrowdStrike Scanning Custom VNet Subnet Role"

  permissions {
    actions = [
      "Microsoft.Network/virtualNetworks/subnets/join/action",
      "Microsoft.Network/virtualNetworks/read",
      "Microsoft.Network/virtualNetworks/subnets/read",
    ]
    not_actions = []
  }

  assignable_scopes = local.custom_subnet_ids
}

# Role assignment for custom VNet subnet access - one per subnet
resource "azurerm_role_assignment" "custom_vnet_subnet" {
  for_each = local.custom_subnet_ids

  scope              = each.value
  role_definition_id = azurerm_role_definition.custom_vnet_subnet[0].role_definition_resource_id
  principal_id       = var.agentless_scanning_principal_id
  principal_type     = "ServicePrincipal"
}
