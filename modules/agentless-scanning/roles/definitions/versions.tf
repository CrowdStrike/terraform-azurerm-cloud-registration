terraform {
  required_version = ">= 1.3, != 1.15.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.42.0"
    }
  }
}
