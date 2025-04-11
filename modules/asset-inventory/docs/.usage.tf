terraform {
  required_version = ">= 0.15"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.63.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "asset_inventory" {
  source = "CrowdStrike/cloud-registration/azure//modules/asset-inventory"

  # Option 1: Specify subscription IDs directly
  subscription_ids = ["subscription-id-1", "subscription-id-2"]

  # Option 2: Use management groups
  management_group_ids = ["mg-id-1", "mg-id-2"]

  # Service principal object ID that will be granted permissions
  # This can be obtained from the service-principal module output
  object_id = "00000000-0000-0000-0000-000000000000"
}
