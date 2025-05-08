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

      configuration_aliases = [azurerm.existing_activity_log_eventhub, azurerm.existing_entra_id_log_eventhub]
    }
  }
}
