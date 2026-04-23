locals {
  mg_scope = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"

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

  conditional_public_ip_actions = [
    "Microsoft.Network/publicIPAddresses/read",
    "Microsoft.Network/publicIPAddresses/write",
    "Microsoft.Network/publicIPAddresses/join/action"
  ]
}

# Custom role for subscription-level scanning access (MG-scoped)
resource "azurerm_role_definition" "subscription_access" {
  name        = "${var.resource_prefix}role-csscanning-access-${var.management_group_id}${var.resource_suffix}"
  scope       = local.mg_scope
  description = "CrowdStrike Agentless Scanning Subscription Access Role"

  permissions {
    actions = [
      "Microsoft.Storage/storageAccounts/read",
      "Microsoft.Storage/storageAccounts/PrivateEndpointConnectionsApproval/action",
      "Microsoft.Authorization/roleAssignments/read",
      "Microsoft.Authorization/policyDefinitions/read",
    ]
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
      local.host_rg_access_actions,
      !var.agentless_scanning_deploy_nat_gateway ? local.conditional_public_ip_actions : []
    )
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
    actions = [
      "Microsoft.Storage/storageAccounts/blobServices/containers/read",
    ]
    not_actions = []
    data_actions = [
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
    ]
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
    actions = [
      "Microsoft.Network/virtualNetworks/subnets/join/action",
      "Microsoft.Network/virtualNetworks/read",
      "Microsoft.Network/virtualNetworks/subnets/read",
    ]
    not_actions = []
  }

  assignable_scopes = [local.mg_scope]
}
