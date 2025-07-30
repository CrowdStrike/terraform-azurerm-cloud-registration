terraform {
  required_version = ">= 1.9.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 1.6.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "00000000-0000-0000-0000-000000000000" # Replace with your subscription ID that will host CrowdStrike's infrastructure resources
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
  resource_group_name = "crowdstrike-rg"

  # Scope of monitoring
  subscription_ids = ["subscription-id-1", "subscription-id-2"]

  # Optional: Configure Activity Log settings
  activity_log_settings = {
    enabled = true
    # To use existing Event Hub resource ID and consumer group name, specify this section with existing_eventhub.use = true and provide existing Event Hub resource ID and consumer group name
    # existing_eventhub = {
    #     use = true
    #     eventhub_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing-eventhub/providers/Microsoft.EventHub/namespaces/existing-eventhub-namespace/eventhubs/existing-eventhub"
    #     eventhub_consumer_group_name = "$Default"
    # }
  }

  # Optional: Configure Microsoft Entra ID Log settings
  entra_id_log_settings = {
    enabled = true
    # To use existing Event Hub resource ID and consumer group name, specify this section with existing_eventhub.use = true and provide existing Event Hub resource ID and consumer group name
    # existing_eventhub = {
    #     use = true
    #     eventhub_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing-eventhub/providers/Microsoft.EventHub/namespaces/existing-eventhub-namespace/eventhubs/existing-eventhub"
    #     eventhub_consumer_group_name = "$Default"
    # }
  }

  # Azure subscription that will host CrowdStrike infrastructure.
  cs_infra_subscription_id = "00000000-0000-0000-0000-000000000000"

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
    CSTagVendor = "CrowdStrike"
  }
}
