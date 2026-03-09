locals {
  should_deploy_scanning_environment = var.agentless_scanning_host_subscription_id == ""
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

  resource_group_name                   = var.deploy_resource_group ? module.crowdstrike_resource_group[0].resource_group_name : var.resource_group_name
  falcon_client_id                      = var.falcon_client_id
  falcon_client_secret                  = var.falcon_client_secret
  agentless_scanning_deploy_nat_gateway = var.agentless_scanning_deploy_nat_gateway
  agentless_scanning_locations          = var.agentless_scanning_locations
  key_vault_allowed_ip_rules            = var.key_vault_allowed_ip_rules
  resource_prefix                       = var.resource_prefix
  resource_suffix                       = var.resource_suffix
  env                                   = var.env
  tags                                  = var.tags

  depends_on = [module.crowdstrike_resource_group]
}

module "agentless_scanning_role" {
  source = "./role"

  resource_group_name                     = var.deploy_resource_group ? module.crowdstrike_resource_group[0].resource_group_name : var.resource_group_name
  agentless_scanner_identity_principal_id = local.should_deploy_scanning_environment ? module.agentless_scanning_environment[0].scanner_identity_principal_id : var.agentless_scanner_identity_principal_id
  agentless_scanning_principal_id         = var.agentless_scanning_principal_id
  agentless_scanning_deploy_nat_gateway   = var.agentless_scanning_deploy_nat_gateway
  resource_prefix                         = var.resource_prefix
  resource_suffix                         = var.resource_suffix

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
  resource_prefix                               = var.resource_prefix
  resource_suffix                               = var.resource_suffix
  env                                           = var.env
  tags                                          = var.tags
}
