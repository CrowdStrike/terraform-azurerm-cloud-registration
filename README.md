<!-- BEGIN_TF_DOCS -->
![CrowdStrike Registration terraform module](https://raw.githubusercontent.com/CrowdStrike/falconpy/main/docs/asset/cs-logo.png)

[![Twitter URL](https://img.shields.io/twitter/url?label=Follow%20%40CrowdStrike&style=social&url=https%3A%2F%2Ftwitter.com%2FCrowdStrike)](https://twitter.com/CrowdStrike)<br/>

# Azure Falcon Cloud Security Terraform Module

This Terraform module enables registration and configuration of Azure accounts with CrowdStrike's Falcon Cloud Security.

Key features:
- Service Principal creation with Microsoft Graph permissions
- Asset Inventory configuration for both subscription and management group scopes
- Real-time visibility with log ingestion (Activity Logs and Entra ID logs)
- Automatic discovery of active subscriptions within management groups

## Pre-requisites

- Azure credentials with Global Administrator or Application Administrator permissions
- Ability to create service principals and assign API permissions in Azure AD
- Subscription Owner or User Access Administrator role to assign custom roles

## Usage

```hcl
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

provider "azuread" {
}

module "crowdstrike_azure_registration" {
  source = "CrowdStrike/cloud-registration/azure"

  # CrowdStrike multi-tenant application client ID
  azure_client_id = "0805b105-a007-49b3-b575-14eed38fc1d0"
  
  # Azure configuration - You can use subscriptions, management groups, or both
  subscription_ids = ["subscription-id-1", "subscription-id-2"]
  management_group_ids = ["mg-id-1", "mg-id-2"]
  
  # Falcon API credentials
  falcon_cid           = "your-falcon-cid"
  falcon_client_id     = "your-falcon-client-id"
  falcon_client_secret = "your-falcon-client-secret"
  
  # Azure subscription that will host CrowdStrike infrastructure
  cs_infra_subscription_id = "your-infrastructure-subscription-id"
  
  # Optional: Enable real-time visibility with log ingestion
  enable_realtime_visibility = true
  
  # Optional: Deploy remediation policy for real-time visibility
  deploy_realtime_visibility_remediation_policy = true
  
  # Optional: Configure Activity Log settings
  realtime_visibility_activity_log_settings = {
    enabled = true
    existing_eventhub = {
      use = false
      # If use = true, provide existing Event Hub details
    }
  }
  
  # Optional: Configure Entra ID Log settings
  realtime_visibility_entra_id_log_settings = {
    enabled = true
    existing_eventhub = {
      use = false
      # If use = true, provide existing Event Hub details
    }
  }
  
  # Optional: Customize Microsoft Graph app roles
  # custom_entra_id_permissions = [
  #   "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30", # Application.Read.All
  #   "98830695-27a2-44f7-8c18-0c3ebc9698f6"  # GroupMember.Read.All
  # ]
}
```

## Providers

| Name                                                                 | Version   |
|----------------------------------------------------------------------|-----------|
| [azuread](https://registry.terraform.io/providers/hashicorp/azuread) | >= 1.6.0  |
| [azurerm](https://registry.terraform.io/providers/hashicorp/azurerm) | >= 3.63.0 |

## Resources

| Name                                                                                                                              | Type        |
|-----------------------------------------------------------------------------------------------------------------------------------|-------------|
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription)   | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group)     | resource    |

## Modules

| Name                                              | Source                       | Description                                                                                          |
|---------------------------------------------------|------------------------------|------------------------------------------------------------------------------------------------------|
| [service_principal](./modules/service-principal/) | ./modules/service-principal/ | Creates and configures the service principal with Microsoft Graph permissions                        |
| [asset_inventory](./modules/asset-inventory/)     | ./modules/asset-inventory/   | Configures Azure asset inventory with custom roles for both subscription and management group scopes |
| [deployment_scope](./modules/deployment-scope/)   | ./modules/deployment-scope/  | Discovers active subscriptions within management groups                                              |
| [log_ingestion](./modules/log-ingestion/)         | ./modules/log-ingestion/     | Configures log ingestion for real-time visibility (Activity Logs and Entra ID logs)                  |

## Inputs

| Name                                          | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                | Type           | Default                                         | Required |
|-----------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|-------------------------------------------------|:--------:|
| tenant_id                                     | Azure tenant ID for deployment. If not provided, it will be automatically retrieved from the current Azure client configuration.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | `string`       | `""`                                            |    no    |
| management_group_ids                          | List of Azure management group IDs to monitor with CrowdStrike Falcon Cloud Security. All subscriptions within these management groups will be automatically discovered and monitored.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | `list(string)` | `[]`                                            |    no    |
| subscription_ids                              | List of specific Azure subscription IDs to monitor with CrowdStrike Falcon Cloud Security. Use this for targeted monitoring of individual subscriptions.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | `list(string)` | `[]`                                            |    no    |
| cs_infra_subscription_id                      | Azure subscription ID where CrowdStrike infrastructure resources (such as Event Hubs) will be deployed. This subscription must be accessible with the current credentials.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | `string`       | `""`                                            |   yes    |
| falcon_ip_addresses                           | List of CrowdStrike Falcon service IP addresses to be allowed in network security configurations. Refer to https://falcon.crowdstrike.com/documentation/page/re07d589/add-crowdstrike-ip-addresses-to-cloud-provider-allowlists-0 for the IP address list specific to your Falcon cloud region.                                                                                                                                                                                                                                                                                                                                                                                                                                                            | `list(string)` | `[]`                                            |    no    |
| azure_client_id                               | Client ID of CrowdStrike's multi-tenant application in Azure. This is typically provided by CrowdStrike and is used to establish the connection between Azure and Falcon Cloud Security.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | `string`       | `""`                                            |   yes    |
| custom_entra_id_permissions                   | Optional list of Microsoft Graph permission IDs to assign to the service principal. If provided, these will replace the default permissions. Must include 'Application.Read.All' (ID: 9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30) at minimum.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | `list(string)` | `null`                                          |    no    |
| env                                           | Environment identifier used in resource naming and tagging. Examples include 'prod', 'dev', 'test', etc. Limited to 4 alphanumeric characters for compatibility with resource naming restrictions.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | `string`       | `prod`                                          |    no    |
| region                                        | Azure region where global resources (Role definitions, Event Hub, etc.) will be deployed. These tenant-wide resources only need to be created once regardless of how many subscriptions are monitored.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | `string`       | `westus`                                        |    no    |
| resource_prefix                               | Prefix to add to all resource names created by this module. Useful for organization and to avoid naming conflicts when deploying multiple instances of this module.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | `string`       | `""`                                            |    no    |
| resource_suffix                               | Suffix to add to all resource names created by this module. Useful for organization and to avoid naming conflicts when deploying multiple instances of this module.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | `string`       | `""`                                            |    no    |
| tags                                          | Map of tags to be applied to all resources created by this module. Default includes the CrowdStrike vendor tag.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | `map(string)`  | `{}`                                            |    no    |
| enable_realtime_visibility                    | Enable real-time visibility by configuring log ingestion for Azure Activity Logs and Entra ID logs. This provides enhanced security monitoring capabilities.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | `bool`         | `false`                                         |    no    |
| deploy_realtime_visibility_remediation_policy | When 'enable_realtime_visibility' is true, this option deploys an Azure Policy at each management group to automatically configure activity log diagnostic settings for EventHub in subscriptions where these settings are missing. Note that diagnostic settings deployed by this policy will not be tracked or managed by Terraform.                                                                                                                                                                                                                                                                                                                                                                                                                     | `bool`         | `false`                                         |    no    |
| realtime_visibility_activity_log_settings     | Configuration settings for Azure Activity Log ingestion when 'enable_realtime_visibility' is true. Structure:<br>- `enabled` - (bool) Enable Activity Log ingestion<br>- `existing_eventhub` - (object) Configuration for using an existing Event Hub:<br>  - `use` - (bool) Whether to use an existing Event Hub<br>  - `subscription_id` - (string) Subscription ID where the Event Hub exists<br>  - `resource_group_name` - (string) Resource group containing the Event Hub<br>  - `namespace_name` - (string) Event Hub Namespace name<br>  - `name` - (string) Event Hub name<br>  - `consumer_group_name` - (string) Consumer group name<br>  - `authorization_rule_id` - (string) Authorization rule ID for the Event Hub                         | `object`       | `{enabled=true, existing_eventhub={use=false}}` |    no    |
| realtime_visibility_entra_id_log_settings     | Configuration settings for Microsoft Entra ID (formerly Azure AD) log ingestion when 'enable_realtime_visibility' is true. Structure:<br>- `enabled` - (bool) Enable Entra ID Log ingestion<br>- `existing_eventhub` - (object) Configuration for using an existing Event Hub:<br>  - `use` - (bool) Whether to use an existing Event Hub<br>  - `subscription_id` - (string) Subscription ID where the Event Hub exists<br>  - `resource_group_name` - (string) Resource group containing the Event Hub<br>  - `namespace_name` - (string) Event Hub Namespace name<br>  - `name` - (string) Event Hub name<br>  - `consumer_group_name` - (string) Consumer group name<br>  - `authorization_rule_id` - (string) Authorization rule ID for the Event Hub | `object`       | `{enabled=true, existing_eventhub={use=false}}` |    no    |

## Outputs

| Name                           | Description                                                                                                            |
|--------------------------------|------------------------------------------------------------------------------------------------------------------------|
| tenant_id                      | Azure tenant ID used for CrowdStrike Falcon Cloud Security integration                                                 |
| service_principal_object_id    | Object ID of the CrowdStrike service principal used for Azure resource access                                          |
| subscription_scopes            | List of Azure subscription scopes configured for CrowdStrike Falcon Cloud Security asset inventory                     |
| management_group_scopes        | List of Azure management group scopes configured for CrowdStrike Falcon Cloud Security asset inventory                 |
| active_subscriptions_in_groups | Map of Azure management group scopes to active Azure subscriptions discovered within those groups                      |
| activity_log_settings          | Configuration settings for Azure Activity Log ingestion via Event Hub for real-time visibility                         |
| entra_id_log_settings          | Configuration settings for Microsoft Entra ID (formerly Azure AD) log ingestion via Event Hub for real-time visibility |

<!-- END_TF_DOCS -->
