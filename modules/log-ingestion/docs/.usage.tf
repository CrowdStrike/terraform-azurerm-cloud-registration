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

# First, create a service principal using the service-principal module
module "service_principal" {
  source = "CrowdStrike/cloud-registration/azure//modules/service-principal"

  azure_client_id = "0805b105-a007-49b3-b575-14eed38fc1d0"
}

# Configure log ingestion
module "log_ingestion" {
  source = "CrowdStrike/cloud-registration/azure//modules/log-ingestion"
  providers = {
    azurerm.existing_activity_log_eventhub = azurerm.existing_activity_log_eventhub
    azurerm.existing_entra_id_log_eventhub = azurerm.existing_entra_id_log_eventhub
  }

  # Service principal ID from the service-principal module
  app_service_principal_id = module.service_principal.object_id

  # CrowdStrike Falcon details
  falcon_cid           = "abcdef0123456789abcdef0123456789"     # Your Falcon CID
  falcon_client_id     = "abcdef01-2345-6789-abcd-ef0123456789" # Your Falcon API Client ID
  falcon_client_secret = "YOUR_FALCON_CLIENT_SECRET"

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
      # If use = true, provide these values:
      # subscription_id       = "00000000-0000-0000-0000-000000000000"
      # resource_group_name   = "existing-rg"
      # namespace_name        = "existing-namespace"
      # name                  = "existing-eventhub"
      # consumer_group_name   = "$Default"
      # authorization_rule_id = "/subscriptions/.../authorizationRules/RootManageSharedAccessKey"
    }
  }

  # Optional: Configure Entra ID Log settings
  entra_id_log_settings = {
    enabled = true
    existing_eventhub = {
      use = false
      # Same parameters as activity_log_settings.existing_eventhub if use = true
    }
  }

  # Optional: Deploy remediation policy
  deploy_remediation_policy = true

  # Optional: Resource naming
  resource_prefix = "cs-"
  resource_suffix = "-prod"

  # Optional: Tagging
  tags = {
    Environment = "Production"
    CSTagVendor = "Crowdstrike"
  }
}
