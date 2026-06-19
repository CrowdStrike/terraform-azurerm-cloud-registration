locals {
  # Example secondary subscription for agentless scanning deployment
  # Environment identifier used in resource naming and tagging such as 'prod', 'dev', or 'test'.
  # Limited to 4 alphanumeric characters for compatibility with resource naming restrictions.
  # Set it to empty if you don't want it added to the resource names.
  env = "prod"

  # Controls whether to enable real-time visibility and detection for CrowdStrike Falcon Cloud Security in Azure.
  enable_realtime_visibility = false

  # Controls agentless scanning settings
  enable_dspm                           = true
  enable_vulnerability_scanning         = false
  agentless_scanning_deploy_nat_gateway = true
  agentless_scanning_locations_per_subscription = {
    (var.cs_infra_subscription_id) : ["westus"]
  }

  # Optional: Resource naming customization
  resource_prefix = ""
  resource_suffix = ""

  # Optional: Custom tags
  tags = {
    method = "per-sub"
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

# Optional: for key_vault_allowed_ip_rules
# data "http" "public_ip" {
#   url = "https://ipv4.icanhazip.com"
# }

module "crowdstrike_azure_registration" {
  source = "../../"

  subscription_ids                              = var.subscription_ids
  management_group_ids                          = var.management_group_ids
  cs_infra_subscription_id                      = var.cs_infra_subscription_id
  falcon_client_id                              = var.falcon_client_id
  falcon_client_secret                          = var.falcon_client_secret
  falcon_ip_addresses                           = var.falcon_ip_addresses
  enable_realtime_visibility                    = local.enable_realtime_visibility
  enable_dspm                                   = local.enable_dspm
  enable_vulnerability_scanning                 = local.enable_vulnerability_scanning
  agentless_scanning_locations_per_subscription = local.agentless_scanning_locations_per_subscription
  agentless_scanning_deploy_nat_gateway         = local.agentless_scanning_deploy_nat_gateway
  location                                      = var.location

  # Optional: Restrict Key Vault network access to specific IP addresses or CIDR  blocks.
  # Note that terraform caller IP range needs to be allowed to manage KeyVault server.
  # key_vault_allowed_ip_rules            = ["${chomp(data.http.public_ip.response_body)}/32"]

  # Optional: Resource naming customization
  resource_prefix = local.resource_prefix
  resource_suffix = local.resource_suffix
  env             = local.env

  tags = local.tags
}

# For each subscription where you want to onboard agentless scanning features (like DSPM):
# - duplicate this module and the provider
# - update the `provider` with desired subscription and alias

