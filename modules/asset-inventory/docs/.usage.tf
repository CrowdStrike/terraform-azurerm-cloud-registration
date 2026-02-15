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
  subscription_id = "00000000-0000-0000-0000-000000000000" # Replace with your subscription ID that will host CrowdStrike's infrastructure resources
  features {}
}

module "asset_inventory" {
  source = "CrowdStrike/cloud-registration/azurerm//modules/asset-inventory"

  tenant_id = "11111111-1111-1111-1111-111111111111"
  # Specify subscription IDs directly
  subscription_ids = ["subscription-id-1", "subscription-id-2"]
  # AND use management groups
  management_group_ids = ["mg-id-1", "mg-id-2"]

  # Service principal object ID that will be granted permissions
  # This can be obtained from the service-principal module output
  app_service_principal_id = "00000000-0000-0000-0000-000000000000"

  # Optional: Resource naming
  resource_prefix = "cs-"
  resource_suffix = "-prod"
}
