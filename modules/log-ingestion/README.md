<!-- BEGIN_TF_DOCS -->
# CrowdStrike Log Ingestion Terraform Module for Azure

![CrowdStrike Log Ingestion terraform module](https://raw.githubusercontent.com/CrowdStrike/falconpy/main/docs/asset/cs-logo.png)

[![Twitter URL](https://img.shields.io/twitter/url?label=Follow%20%40CrowdStrike&style=social&url=https%3A%2F%2Ftwitter.com%2FCrowdStrike)](https://twitter.com/CrowdStrike)

## Introduction

This Terraform module deploys the required Azure resources to enable CrowdStrike's Real-time Visibility feature in Azure environments. It configures log ingestion for Azure Activity Logs and Microsoft Entra ID (formerly Azure AD) logs via Event Hubs.

## Features

- Creates or uses existing Event Hub resources for log ingestion
- Configures diagnostic settings for Azure Activity Logs at subscription level
- Configures diagnostic settings for Microsoft Entra ID logs at tenant level
- Optionally deploys remediation policies to automatically configure diagnostic settings for new subscriptions
- Supports network security with IP allowlisting for CrowdStrike services

## Usage

```hcl
terraform {
  required_version = ">= 0.15"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.63.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "log_ingestion" {
  source = "CrowdStrike/cloud-registration/azure//modules/log-ingestion"

  # Required parameters
  resource_group_name      = "rg-crowdstrike-infra"
  cs_infra_subscription_id = "00000000-0000-0000-0000-000000000000"
  app_service_principal_id = "00000000-0000-0000-0000-000000000000"
  falcon_cid               = "00000000000000000000000000000000"
  falcon_client_id         = "00000000000000000000000000000000"
  falcon_client_secret     = "your-falcon-client-secret"
  
  # Specify subscription IDs to monitor
  subscription_ids = ["subscription-id-1", "subscription-id-2"]
  
  # And/or management groups to monitor
  management_group_ids = ["mg-id-1", "mg-id-2"]
  
  # Optional: Configure Activity Log settings
  activity_log_settings = {
    enabled = true
    existing_eventhub = {
      use = false
      # If use = true, the following parameters are required
      # subscription_id       = "00000000-0000-0000-0000-000000000000"
      # resource_group_name   = "rg-existing-eventhub"
      # namespace_name        = "existing-namespace"
      # name                  = "existing-eventhub"
      # consumer_group_name   = "$Default"
      # authorization_rule_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing-eventhub/providers/Microsoft.EventHub/namespaces/existing-namespace/authorizationRules/RootManageSharedAccessKey"
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
  
  # Optional: CrowdStrike IP addresses for network security
  falcon_ip_addresses = ["1.2.3.4", "5.6.7.8"]
}
```

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.63.0 |

## Resources

| Name                                                                                                                                                                            | Type        |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [azurerm_monitor_diagnostic_setting.activity-log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting)                   | resource    |
| [azurerm_monitor_aad_diagnostic_setting.entra-id-log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_aad_diagnostic_setting)           | resource    |
| [azurerm_policy_definition.activity-log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition)                                     | resource    |
| [azurerm_management_group_policy_assignment.activity-log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_policy_assignment)   | resource    |
| [azurerm_management_group_policy_remediation.activity-log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_policy_remediation) | resource    |
| [azurerm_role_assignment.activity-log-eventhub-data-receiver](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)                  | resource    |
| [azurerm_role_assignment.entra-id-eventhub-data-receiver](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)                      | resource    |
| [azurerm_role_assignment.activity-log-policy-monitoring-contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)           | resource    |
| [azurerm_role_assignment.activity-log-policy-lab-services-reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)              | resource    |
| [azurerm_role_assignment.activity-log-policy-lab-azure-eventhubs-data-owner](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)   | resource    |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription)                                                 | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config)                                               | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group)                                                | data source |

## Modules

| Name                                                           | Source                       | Description                                                        |
|----------------------------------------------------------------|------------------------------|--------------------------------------------------------------------|
| [new_eventhub](./modules/eventhub/)                            | ./modules/eventhub/          | Creates a new Event Hub namespace and Event Hubs for log ingestion |
| [existing_activity_log_eventhub](./modules/existing-eventhub/) | ./modules/existing-eventhub/ | References an existing Event Hub for Activity Log ingestion        |
| [existing_entra_id_log_eventhub](./modules/existing-eventhub/) | ./modules/existing-eventhub/ | References an existing Event Hub for Entra ID log ingestion        |

## Inputs

| Name                      | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | Type           | Default                                         | Required |
|---------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|-------------------------------------------------|:--------:|
| tenant_id                 | Azure tenant ID (optional - will be retrieved from current client config if not provided)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | `string`       | `""`                                            |    no    |
| management_group_ids      | List of management group IDs to monitor                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | `list(string)` | `[]`                                            |    no    |
| subscription_ids          | List of subscription IDs to monitor                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | `list(string)` | `[]`                                            |    no    |
| app_service_principal_id  | Service principal ID of Crowdstrike app to which all the roles will be assigned                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | `string`       | n/a                                             |   yes    |
| falcon_cid                | Falcon CID                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | `string`       | n/a                                             |   yes    |
| falcon_client_id          | Client ID for the Falcon API                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | `string`       | n/a                                             |   yes    |
| falcon_client_secret      | Client secret for the Falcon API                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | `string`       | n/a                                             |   yes    |
| falcon_url                | Falcon cloud API url                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | `string`       | `"api.crowdstrike.com"`                         |    no    |
| falcon_ip_addresses       | List of IPv4 addresses of Crowdstrike Falcon service                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | `list(string)` | `[]`                                            |    no    |
| cs_infra_subscription_id  | Azure subscription ID that will host CrowdStrike infrastructure                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | `string`       | n/a                                             |   yes    |
| resource_group_name       | Resource group name that will host CrowdStrike infrastructure                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | `string`       | n/a                                             |   yes    |
| deploy_remediation_policy | Deploy a Azure Policy at each management group to automatically configure activity log diagnostic settings                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | `bool`         | `false`                                         |    no    |
| activity_log_settings     | Settings of realtime visibility for activity log. Structure:<br>- `enabled` - (bool) Enable Activity Log ingestion<br>- `existing_eventhub` - (object) Configuration for using an existing Event Hub:<br>  - `use` - (bool) Whether to use an existing Event Hub<br>  - `subscription_id` - (string) Subscription ID where the Event Hub exists<br>  - `resource_group_name` - (string) Resource group containing the Event Hub<br>  - `namespace_name` - (string) Event Hub Namespace name<br>  - `name` - (string) Event Hub name<br>  - `consumer_group_name` - (string) Consumer group name<br>  - `authorization_rule_id` - (string) Authorization rule ID for the Event Hub | `object`       | `{enabled=true, existing_eventhub={use=false}}` |    no    |
| entra_id_log_settings     | Settings of realtime visibility for Entra ID log. Structure:<br>- `enabled` - (bool) Enable Entra ID Log ingestion<br>- `existing_eventhub` - (object) Configuration for using an existing Event Hub:<br>  - `use` - (bool) Whether to use an existing Event Hub<br>  - `subscription_id` - (string) Subscription ID where the Event Hub exists<br>  - `resource_group_name` - (string) Resource group containing the Event Hub<br>  - `namespace_name` - (string) Event Hub Namespace name<br>  - `name` - (string) Event Hub name<br>  - `consumer_group_name` - (string) Consumer group name<br>  - `authorization_rule_id` - (string) Authorization rule ID for the Event Hub | `object`       | `{enabled=true, existing_eventhub={use=false}}` |    no    |
| env                       | Custom label indicating the environment to be monitored                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | `string`       | `"prod"`                                        |    no    |
| region                    | Azure region for the resources deployed in this solution                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | `string`       | `"westus"`                                      |    no    |
| resource_prefix           | The prefix to be added to the resource name                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | `string`       | `""`                                            |    no    |
| resource_suffix           | The suffix to be added to the resource name                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | `string`       | `""`                                            |    no    |
| tags                      | Tags to be applied to all resources                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | `map(string)`  | `{ CSTagVendor = "Crowdstrike" }`               |    no    |

## Outputs

| Name                                      | Description                                                           |
|-------------------------------------------|-----------------------------------------------------------------------|
| activity_log_eventhub_namespace_id        | Resource ID of the EventHub namespace for activity log                |
| activity_log_eventhub_namespace_name      | Name of the EventHub namespace for activity log                       |
| activity_log_eventhub_id                  | Resource ID of the EventHub instance for activity log                 |
| activity_log_eventhub_name                | Name of the EventHub instance for activity log                        |
| activity_log_eventhub_consumer_group_name | Name of the consumer group of the EventHub for consuming activity log |
| entra_id_log_eventhub_namespace_id        | Resource ID of the EventHub namespace for Entra ID log                |
| entra_id_log_eventhub_namespace_name      | Name of the EventHub namespace for Entra ID log                       |
| entra_id_log_eventhub_id                  | Resource ID of the EventHub instance for Entra ID log                 |
| entra_id_log_eventhub_name                | Name of the EventHub instance for Entra ID log                        |
| entra_id_log_eventhub_consumer_group_name | Name of the consumer group of the EventHub for consuming Entra ID log |

<!-- END_TF_DOCS -->
