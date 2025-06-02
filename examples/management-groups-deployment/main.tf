locals {
  # Environment identifier used in resource naming and tagging. Examples include 'prod', 'dev', 'test', etc. 
  # Limited to 4 alphanumeric characters for compatibility with resource naming restrictions.
  # Set it to empty if you don't want it added to the resource names.
  env = "prod"

  # Controls whether to enable Real Time Visibility and Detection feature for CrowdStrike Falcon Cloud Security in Azure.
  enable_realtime_visibility = true

  # Prefix/Suffix to be added to all created resource names for identification
  resource_prefix = "pfx-"
  resource_suffix = "-sux"

  # Map of tags to be applied to all resources created by this module.
  tags = {
    DeployedBy = var.me
    Product    = "FalconCloudSecurity"
  }
}

provider "azurerm" {
  subscription_id = var.cs_infra_subscription_id
  features {}
}

provider "azuread" {
}

provider "crowdstrike" {
  client_id     = var.falcon_client_id
  client_secret = var.falcon_client_secret
}

module "crowdstrike_azure_registration" {
  source = "CrowdStrike/cloud-registration/azurerm"

  subscription_ids           = var.subscription_ids
  management_group_ids       = var.management_group_ids
  cs_infra_subscription_id   = var.cs_infra_subscription_id
  falcon_client_id           = var.falcon_client_id
  falcon_client_secret       = var.falcon_client_secret
  falcon_ip_addresses        = var.falcon_ip_addresses
  enable_realtime_visibility = local.enable_realtime_visibility
  env                        = local.env
  location                   = var.location
  resource_prefix            = local.resource_prefix
  resource_suffix            = local.resource_suffix
  tags                       = local.tags
}
