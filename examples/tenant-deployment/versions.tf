terraform {
  required_version = ">= 1.8.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 1.6.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
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
