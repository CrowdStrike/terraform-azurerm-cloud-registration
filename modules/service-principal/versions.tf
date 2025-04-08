terraform {
  required_version = ">= 0.15"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 1.6.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.63.0"
    }

    # it is temporal provider used until official public provider ready
    crowdstrike = {
      source  = "cs-dev-cloudconnect-templates.s3.amazonaws.com/crowdstrike/crowdstrike"
      version = ">= 0.2.0"
    }
  }
}
