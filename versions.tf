terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 1.6.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }

    time = {
      source  = "hashicorp/time"
      version = ">= 0.13.1"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }

    crowdstrike = {
      source  = "CrowdStrike/crowdstrike"
      version = ">= 0.0.29"
    }
  }
}
