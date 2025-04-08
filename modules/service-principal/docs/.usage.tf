terraform {
  required_version = ">= 0.15"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.63.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 1.6.0"
    }
    crowdstrike = {
      source  = "cs-dev-cloudconnect-templates.s3.amazonaws.com/crowdstrike/crowdstrike"
      version = ">= 0.2.0"
    }
  }
}

variable "falcon_client_id" {
  type        = string
  sensitive   = true
  description = "Falcon API Client ID"
}

variable "falcon_client_secret" {
  type        = string
  sensitive   = true
  description = "Falcon API Client Secret"
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

provider "crowdstrike" {
  client_id     = var.falcon_client_id
  client_secret = var.falcon_client_secret
}

# Create service principal and register tenant with CrowdStrike
module "service_principal" {
  source = "CrowdStrike/cloud-registration/azure//modules/service-principal"

  # Use management group for automatic subscription discovery
  use_azure_management_group = true
  default_subscription_id    = "00000000-0000-0000-0000-000000000000" # Replace with your subscription ID
  
  # Optional: For GovCloud environments
  # is_commercial = true
}

output "service_principal_object_id" {
  value     = module.service_principal.object_id
  sensitive = true
}

output "monitored_subscriptions" {
  value = module.asset_inventory.subscriptions
}
