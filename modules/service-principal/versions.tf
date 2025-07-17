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
  }
}
