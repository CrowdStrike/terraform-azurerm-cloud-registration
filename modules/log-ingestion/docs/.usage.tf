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
  subscription_id = "00000000-0000-0000-0000-000000000000" # Replace with your subscription ID that will host Crowdstrike's infrastructure resources
  features {}
}

provider "azuread" {
}

# First, create a service principal using the service-principal module
module "service_principal" {
  source = "CrowdStrike/cloud-registration/azure//modules/service-principal"

  azure_client_id = "0805b105-a007-49b3-b575-14eed38fc1d0"
}

# Configure log ingestion
module "log_ingestion" {
  source = "CrowdStrike/cloud-registration/azure//modules/log-ingestion"
  providers = {
    azurerm = azurerm
  }

  # Service principal ID from the service-principal module
  app_service_principal_id = module.service_principal.object_id

  # Azure infrastructure details
  resource_group_name      = "crowdstrike-rg"
  cs_infra_subscription_id = "00000000-0000-0000-0000-000000000000"

  # Scope of monitoring
  subscription_ids     = ["subscription-id-1", "subscription-id-2"]
  management_group_ids = ["mg-id-1", "mg-id-2"]

  # Optional: Configure Activity Log settings
  activity_log_settings = {
    enabled = true
    existing_eventhub = {
      use = false
      # If use = true, provide this value:
      # eventhub_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/existing-rg/providers/Microsoft.EventHub/namespaces/existing-namespace/eventhubs/existing-eventhub"
    }
  }

  # Optional: Configure Entra ID Log settings
  entra_id_log_settings = {
    enabled = true
    existing_eventhub = {
      use = false
      # If use = true, provide this value:
      # eventhub_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/existing-rg/providers/Microsoft.EventHub/namespaces/existing-namespace/eventhubs/existing-eventhub"
    }
  }

  # Optional: Deploy remediation policy
  deploy_remediation_policy = true

  # Optional: CrowdStrike IP addresses for network security
  falcon_ip_addresses = ["1.2.3.4", "5.6.7.8"]

  # Optional: Resource naming
  resource_prefix = "cs-"
  resource_suffix = "-prod"
  env             = "prod"
  location        = "westus"

  # Optional: Tagging
  tags = {
    Environment = "Production"
    CSTagVendor = "Crowdstrike"
  }
}
