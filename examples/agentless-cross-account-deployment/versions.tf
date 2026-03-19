terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.42.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }

    crowdstrike = {
      source  = "CrowdStrike/crowdstrike"
      version = ">= 0.0.66"
    }

    http = {
      source  = "hashicorp/http"
      version = ">= 3.0.0"
    }
  }
}
