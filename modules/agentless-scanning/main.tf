locals {
  should_deploy_scanning_environment = var.agentless_scanning_host_subscription_id == ""

  # For the host: use internal MG roles if host is in an MG, otherwise use external scanning_role_definition_ids
  effective_role_definition_ids = var.host_mg_id != "" ? module.agentless_scanning_roles_mg[var.host_mg_id].role_definition_ids : var.scanning_role_definition_ids

  # Single source of truth for all role action definitions
  role_actions = {
    subscription_access_actions = [
      "Microsoft.Storage/storageAccounts/read",
      "Microsoft.Storage/storageAccounts/PrivateEndpointConnectionsApproval/action",
      "Microsoft.Authorization/roleAssignments/read",
      "Microsoft.Authorization/policyDefinitions/read",
    ]
    host_rg_access_actions = [
      # Blob Storage
      "Microsoft.Network/privateEndpoints/read",
      "Microsoft.Network/privateEndpoints/write",
      "Microsoft.Network/privateEndpoints/delete",
      "Microsoft.Network/virtualNetworks/subnets/join/action",
      # Scanner VM
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
      # Validation
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
      "Microsoft.Network/publicIPAddresses/join/action",
    ]
    subscription_scanner_actions = [
      "Microsoft.Storage/storageAccounts/blobServices/containers/read",
    ]
    subscription_scanner_data_actions = [
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
    ]
    custom_vnet_subnet_actions = [
      "Microsoft.Network/virtualNetworks/subnets/join/action",
      "Microsoft.Network/virtualNetworks/read",
      "Microsoft.Network/virtualNetworks/subnets/read",
    ]
  }
}

module "agentless_scanning_roles_mg" {
  for_each = var.management_group_scopes
  source   = "./roles-mg"

  management_group_id                   = each.value
  agentless_scanning_deploy_nat_gateway = var.agentless_scanning_deploy_nat_gateway
  use_custom_subnets                    = length(var.agentless_scanning_custom_vnet_configuration) > 0
  resource_prefix                       = var.resource_prefix
  resource_suffix                       = var.resource_suffix
  role_actions                          = local.role_actions
}

module "crowdstrike_resource_group" {
  count  = var.deploy_resource_group ? 1 : 0
  source = "../resource-group"

  resource_prefix = var.resource_prefix
  resource_suffix = var.resource_suffix
  env             = var.env
}

module "agentless_scanning_environment" {
  count  = local.should_deploy_scanning_environment ? 1 : 0
  source = "./environment"

  resource_group_name                          = var.deploy_resource_group ? module.crowdstrike_resource_group[0].resource_group_name : var.resource_group_name
  falcon_client_id                             = var.falcon_client_id
  falcon_client_secret                         = var.falcon_client_secret
  agentless_scanning_deploy_nat_gateway        = var.agentless_scanning_deploy_nat_gateway
  agentless_scanning_locations                 = var.agentless_scanning_locations
  agentless_scanning_custom_vnet_configuration = var.agentless_scanning_custom_vnet_configuration
  key_vault_allowed_ip_rules                   = var.key_vault_allowed_ip_rules
  resource_prefix                              = var.resource_prefix
  resource_suffix                              = var.resource_suffix
  env                                          = var.env
  tags                                         = var.tags

  depends_on = [module.crowdstrike_resource_group]
}

module "agentless_scanning_roles" {
  source = "./roles"

  resource_group_name                          = var.deploy_resource_group ? module.crowdstrike_resource_group[0].resource_group_name : var.resource_group_name
  agentless_scanner_identity_principal_id      = local.should_deploy_scanning_environment ? module.agentless_scanning_environment[0].scanner_identity_principal_id : var.agentless_scanner_identity_principal_id
  agentless_scanning_principal_id              = var.agentless_scanning_principal_id
  agentless_scanning_host_subscription_id      = var.agentless_scanning_host_subscription_id
  agentless_scanning_deploy_nat_gateway        = var.agentless_scanning_deploy_nat_gateway
  agentless_scanning_custom_vnet_configuration = var.agentless_scanning_custom_vnet_configuration
  resource_prefix                              = var.resource_prefix
  resource_suffix                              = var.resource_suffix
  external_role_definition_ids                 = local.effective_role_definition_ids
  role_actions                                 = local.role_actions

  depends_on = [module.crowdstrike_resource_group, module.agentless_scanning_environment]
}

module "agentless_scanning_parameters" {
  source = "./scanning-parameters"

  falcon_client_id                              = var.falcon_client_id
  enable_dspm                                   = var.input_enable_dspm
  agentless_scanning_locations                  = var.agentless_scanning_locations
  agentless_scanning_locations_per_subscription = var.input_agentless_scanning_locations_per_subscription
  agentless_scanning_principal_id               = var.agentless_scanning_principal_id
  agentless_scanning_host_subscription_id       = var.agentless_scanning_host_subscription_id
  agentless_scanning_deploy_nat_gateway         = var.agentless_scanning_deploy_nat_gateway
  agentless_scanning_custom_vnet_configuration  = var.agentless_scanning_custom_vnet_configuration
  resource_prefix                               = var.resource_prefix
  resource_suffix                               = var.resource_suffix
  env                                           = var.env
  tags                                          = var.tags
}
