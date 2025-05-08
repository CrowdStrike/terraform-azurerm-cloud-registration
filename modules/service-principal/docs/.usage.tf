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
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

# Create service principal
module "service_principal" {
  source = "CrowdStrike/cloud-registration/azure//modules/service-principal"

  # Client ID of CrowdStrike's multi-tenant app
  azure_client_id = "0805b105-a007-49b3-b575-14eed38fc1d0"

  # Optionally customize Microsoft Graph app roles
  # microsoft_graph_permission_ids = [
  #   "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30", # Application.Read.All
  #   "98830695-27a2-44f7-8c18-0c3ebc9698f6"  # GroupMember.Read.All
  # ]
}
