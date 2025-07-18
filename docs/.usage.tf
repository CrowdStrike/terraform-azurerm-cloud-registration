terraform {
  required_version = ">= 1.8.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 1.6.0"
    }

    crowdstrike = {
      source  = "Crowdstrike/crowdstrike"
      version = ">= 0.0.29"
    }
  }
}

provider "azurerm" {
  subscription_id = "00000000-0000-0000-0000-000000000000" # Replace with your subscription ID that will host CrowdStrike's infrastructure resources
  features {}
}

provider "azuread" {
}

provider "crowdstrike" {
  client_id     = "<Falcon API client ID>"
  client_secret = "<Falcon API client secret>"
}

module "crowdstrike_azure_registration" {
  source = "CrowdStrike/cloud-registration/azurerm"

  # Azure configuration - You can use subscriptions, management groups, or both
  subscription_ids     = ["subscription-id-1", "subscription-id-2"]
  management_group_ids = ["mg-id-1", "mg-id-2"]

  # Azure subscription that will host CrowdStrike infrastructure. Required when `enable_realtime_visibility` is set to `true`.
  cs_infra_subscription_id = "00000000-0000-0000-0000-000000000000"

  # Optional: CrowdStrike API credential. Required when `enable_realtime_visibility` is set to `true`.
  falcon_client_id     = "<Falcon API client ID>"
  falcon_client_secret = "<Falcon API client secret>"

  # Optional: CrowdStrike IP addresses for network security. Required when `enable_realtime_visibility` is set to `true`.
  falcon_ip_addresses = ["1.2.3.4", "5.6.7.8"]

  # Optional: Enable Real Time Visibility and Detection
  enable_realtime_visibility = true

  # Optional: Configure log ingestion settings
  log_ingestion_settings = {
    activity_log = {
      enabled = true
      # To use existing Event Hub resource ID and consumer group name, specify this section with existing_eventhub.use = true and provide existing Event Hub resource ID and consumer group name
      # existing_eventhub = {
      #     use = true
      #     eventhub_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing-eventhub/providers/Microsoft.EventHub/namespaces/existing-eventhub-namespace/eventhubs/existing-eventhub"
      #     eventhub_consumer_group_name = "$Default"
      # }
    }
    entra_id_log = {
      enabled = true
      # To use existing Event Hub resource ID and consumer group name, specify this section with existing_eventhub.use = true and provide existing Event Hub resource ID and consumer group name
      # existing_eventhub = {
      #     use = true
      #     eventhub_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing-eventhub/providers/Microsoft.EventHub/namespaces/existing-eventhub-namespace/eventhubs/existing-eventhub"
      #     eventhub_consumer_group_name = "$Default"
      # }
    }
  }

  # Optional: Customize Microsoft Graph app roles
  # microsoft_graph_permission_ids = [
  #   "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30", # Application.Read.All
  #   "98830695-27a2-44f7-8c18-0c3ebc9698f6", # GroupMember.Read.All
  #   "246dd0d5-5bd0-4def-940b-0421030a5b68", # Policy.Read.All
  #   "230c1aed-a721-4c5d-9cb4-a90514e508ef", # Reports.Read.All
  #   "483bed4a-2ad3-4361-a73b-c83ccdbdc53c", # RoleManagement.Read.All
  #   "df021288-bdef-4463-88db-98f22de89214"  # User.Read.All
  # ]

  # Optional: Resource naming customization
  # env can be empty or exactly 4 alphanumeric characters
  env             = "prod" # or "" for no environment suffix
  location        = "westus"
  resource_prefix = "cs-"
  resource_suffix = "-001"

  # Optional: Custom tags
  tags = {
    Environment = "Production"
    Project     = "CrowdStrike Integration"
    CSTagVendor = "CrowdStrike"
  }
}
