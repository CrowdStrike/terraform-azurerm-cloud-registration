terraform {
  required_version = ">= 0.15"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.63.0"
    }
    crowdstrike = {
      source  = "cs-dev-cloudconnect-templates.s3.amazonaws.com/crowdstrike/crowdstrike"
      version = ">= 0.2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "crowdstrike" {
  client_id     = var.falcon_client_id
  client_secret = var.falcon_client_secret
}

module "asset_inventory" {
  source = "CrowdStrike/cloud-registration/azure//modules/asset-inventory"

  subscription_ids = ["subscription-id-1", "subscription-id-2"]
  # OR use management group for automatic subscription discovery
  # use_azure_management_group = true
}
