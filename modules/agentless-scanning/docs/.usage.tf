terraform {
  required_version = ">= 1.9.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "crowdstrike_agentless_scanning" {
  source = "CrowdStrike/cloud-registration/azurerm//modules/agentless-scanning"

  # Provision new resource group for agentless scanning
  deploy_resource_group = true

  # Principal ID of CrowdStrike app for agentless scanning orchestration
  agentless_scanning_principal_id = "00000000-0000-0000-0000-000000000000"

  # Locations to enable for agentless scanning
  agentless_scanning_locations = ["westus"]

  # Optional: specify if NAT gateway should be deployed
  agentless_scanning_deploy_nat_gateway = true

  # Optional: KeyVault IP allowlist rules
  key_vault_allowed_ip_rules = ["127.0.0.1/32"]

  # Falcon API credentials to store for scanner use
  falcon_client_id     = "00000000000000000000000000000000"
  falcon_client_secret = "0000000000000000000000000000000000000000"

  # Optional: Resource naming
  resource_prefix = "cs-"
  resource_suffix = ""
  env             = "dev"

  # Optional: Custom tags
  tags = {
    "Developer" : "me"
  }
}
