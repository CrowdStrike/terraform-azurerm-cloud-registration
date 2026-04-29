locals {
  # Environment identifier used in resource naming and tagging such as 'prod', 'dev', or 'test'.
  # Limited to 4 alphanumeric characters for compatibility with resource naming restrictions.
  # Set it to empty if you don't want it added to the resource names.
  env = "prod"

  # Controls whether to enable real-time visibility and detection for CrowdStrike Falcon Cloud Security in Azure.
  enable_realtime_visibility = true

  # Controls agentless scanning settings
  enable_dspm                           = true
  agentless_scanning_locations          = ["westus"]
  agentless_scanning_deploy_nat_gateway = false

  # Optional: Resource naming customization
  resource_prefix = ""
  resource_suffix = ""

  # Optional: Custom tags
  tags = {
    method = "cross-sub"
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

data "http" "public_ip" {
  url = "https://ipv4.icanhazip.com"
}

module "crowdstrike_azure_registration" {
  source  = "CrowdStrike/cloud-registration/azurerm"
  version = "~> 0.1.10"

  subscription_ids                      = var.subscription_ids
  management_group_ids                  = var.management_group_ids
  cs_infra_subscription_id              = var.cs_infra_subscription_id
  falcon_client_id                      = var.falcon_client_id
  falcon_client_secret                  = var.falcon_client_secret
  falcon_ip_addresses                   = var.falcon_ip_addresses
  enable_realtime_visibility            = local.enable_realtime_visibility
  enable_dspm                           = local.enable_dspm
  agentless_scanning_locations          = local.agentless_scanning_locations
  agentless_scanning_deploy_nat_gateway = local.agentless_scanning_deploy_nat_gateway
  location                              = var.location

  # Optional: Restrict Key Vault network access to specific IP addresses or CIDR  blocks.
  # Note that terraform caller IP range needs to be allowed to manage KeyVault server.
  # key_vault_allowed_ip_rules            = ["${chomp(data.http.public_ip.response_body)}/32"]

  # Optional: Agentless Scanning Custom Vnet Configuration per location
  # agentless_scanning_custom_vnet_configuration = {
  #    "westus": {
  #      "scanners_subnet_id": "/subscriptions/<subscription_id>/resourceGroups/<resource_group_name>/providers/Microsoft.Network/virtualNetworks/<vnet_name>/subnets/<scanners_subnet>"
  #      "clones_subnet_id": "/subscriptions/<subscription_id>/resourceGroups/<resource_group_name>/providers/Microsoft.Network/virtualNetworks/<vnet_name>/subnets/<clones_subnet>"
  #    }
  #  }

  # Optional: Resource naming customization
  resource_prefix = local.resource_prefix
  resource_suffix = local.resource_suffix
  env             = local.env

  tags = local.tags
}

# For each subscription where you want to onboard agentless scanning features (like DSPM):
# - duplicate this module and the provider
# - update the `provider` with desired subscription and alias
provider "azurerm" {
  subscription_id = "00000000-0000-0000-0000-000000000000"
  features {}
  alias = "target_sub_1"
}

module "agentless_scanning_target_subscription_1" {
  source  = "CrowdStrike/cloud-registration/azurerm//modules/agentless-scanning"
  version = "~> 0.1.10"

  providers = {
    azurerm = azurerm.target_sub_1
  }

  # Target subscription parameters
  agentless_scanning_host_subscription_id = var.cs_infra_subscription_id
  agentless_scanner_identity_principal_id = module.crowdstrike_azure_registration.agentless_scanning_managed_identity_principal_id

  agentless_scanning_principal_id = module.crowdstrike_azure_registration.service_principal_object_id
  agentless_scanning_locations    = local.agentless_scanning_locations
  input_enable_dspm               = local.enable_dspm
  # key_vault_allowed_ip_rules      = ["${chomp(data.http.public_ip.response_body)}/32"]
  falcon_client_id     = var.falcon_client_id
  falcon_client_secret = var.falcon_client_secret

  # Optional: Use MG-scoped role definitions to reduce the number of custom roles.
  # Pass the role IDs from the root module output for the management group this target subscription belongs to.
  # scanning_role_definition_ids = module.crowdstrike_azure_registration.scanning_role_definition_ids_by_mg["<management-group-id>"]

  # Optional: Resource naming customization
  resource_prefix = local.resource_prefix
  resource_suffix = local.resource_suffix
  env             = local.env

  tags = local.tags
}
