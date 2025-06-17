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

    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }

    crowdstrike = {
      source  = "Crowdstrike/crowdstrike"
      version = ">= 0.0.29"
    }
  }
}
