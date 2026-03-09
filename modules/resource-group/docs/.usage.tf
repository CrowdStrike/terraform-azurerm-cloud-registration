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

module "crowdstrike_resource_group" {
  source = "CrowdStrike/cloud-registration/azurerm//modules/resource-group"

  # Optional: Resource group location
  location = "westus"

  # Optional: Resource naming
  resource_prefix = "crwd-"
  resource_suffix = ""
  env             = "prod"
}
