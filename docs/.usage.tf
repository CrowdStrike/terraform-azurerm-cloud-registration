terraform {
  required_version = ">= 0.15"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.63.0"

      configuration_aliases = [azurerm.existing_activity_log_eventhub, azurerm.existing_entra_id_log_eventhub]
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

# Provider aliases for existing Event Hubs
provider "azurerm" {
  alias           = "existing_activity_log_eventhub"
  subscription_id = "00000000-0000-0000-0000-000000000000" # Replace with your subscription ID hosting the EventHub for activity log
  features {}
}

provider "azurerm" {
  alias           = "existing_entra_id_log_eventhub"
  subscription_id = "00000000-0000-0000-0000-000000000000" # Replace with your subscription ID hosting the Eventhub for entra ID log
  features {}
}

module "crowdstrike_azure_registration" {
  source = "CrowdStrike/cloud-registration/azure"
  providers = {
    azurerm.existing_activity_log_eventhub = azurerm.existing_activity_log_eventhub
    azurerm.existing_entra_id_log_eventhub = azurerm.existing_entra_id_log_eventhub
  }

  # Azure tenant ID (optional, will use current context if not specified)
  # tenant_id = "00000000-0000-0000-0000-000000000000"

  # CrowdStrike multi-tenant application client ID
  azure_client_id = "00000000-0000-0000-0000-000000000000"

  # Azure configuration - You can use subscriptions, management groups, or both
  subscription_ids     = ["subscription-id-1", "subscription-id-2"]
  management_group_ids = ["mg-id-1", "mg-id-2"]

  # Azure subscription that will host CrowdStrike infrastructure
  cs_infra_subscription_id = "00000000-0000-0000-0000-000000000000"

  # Optional: Enable real-time visibility with log ingestion
  enable_realtime_visibility = true

  # Optional: Deploy remediation policy for real-time visibility
  deploy_realtime_visibility_remediation_policy = true

  # Optional: Configure Activity Log settings
  realtime_visibility_activity_log_settings = {
    enabled = true
    existing_eventhub = {
      use = false
      # If use = true, provide existing Event Hub details:
      # subscription_id       = "00000000-0000-0000-0000-000000000000"
      # resource_group_name   = "rg-existing-eventhub"
      # namespace_name        = "existing-eventhub-namespace"
      # name                  = "existing-eventhub"
      # consumer_group_name   = "crowdstrike"
      # authorization_rule_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing-eventhub/providers/Microsoft.EventHub/namespaces/existing-eventhub-namespace/eventhubs/existing-eventhub/authorizationRules/RootManageSharedAccessKey"
    }
  }

  # Optional: Configure Entra ID Log settings
  realtime_visibility_entra_id_log_settings = {
    enabled = true
    existing_eventhub = {
      use = false
      # If use = true, provide existing Event Hub details as shown above
    }
  }

  # Optional: Customize Microsoft Graph app roles
  # custom_entra_id_permissions = [
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
  region          = "westus"
  resource_prefix = "cs-"
  resource_suffix = "-001"

  # Optional: Custom tags
  tags = {
    Environment = "Production"
    Project     = "CrowdStrike Integration"
    CSTagVendor = "Crowdstrike"
  }

  # Optional: CrowdStrike Falcon IP addresses for network security configurations
  falcon_ip_addresses = [
    "1.2.3.4",
    "5.6.7.8"
  ]
}
