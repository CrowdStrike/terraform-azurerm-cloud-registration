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

module "deployment_scope" {
  source = "CrowdStrike/cloud-registration/azurerm//modules/deployment-scope"

  # Specify subscription IDs directly
  subscription_ids = ["subscription-id-1", "subscription-id-2"]

  # AND/OR use management groups
  management_group_ids = ["mg-id-1", "mg-id-2"]
}
