<!-- BEGIN_TF_DOCS -->
![CrowdStrike Registration terraform module](https://raw.githubusercontent.com/CrowdStrike/falconpy/main/docs/asset/cs-logo.png)

[![Twitter URL](https://img.shields.io/twitter/url?label=Follow%20%40CrowdStrike&style=social&url=https%3A%2F%2Ftwitter.com%2FCrowdStrike)](https://twitter.com/CrowdStrike)

## Introduction

This Terraform module enables registration and configuration of Azure accounts with CrowdStrike's Falcon Cloud Security. It provides a comprehensive solution for integrating Azure environments with CrowdStrike's cloud security services, including service principal creation, asset inventory configuration, and real-time visibility through log ingestion.

Key features:
- Service Principal creation with Microsoft Graph permissions
- Asset Inventory configuration for both subscription and management group scopes
- Real-time visibility with log ingestion (Activity Logs and Entra ID logs)
- Automatic discovery of active subscriptions within management groups

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
  subscription_id = "00000000-0000-0000-0000-000000000000" # Replace with your subscription ID that will host CrowdStrike's infrastructure resources
  features {}
}

provider "azuread" {
}

module "crowdstrike_azure_registration" {
  source = "CrowdStrike/cloud-registration/azure"
  providers = {
    azurerm = azurerm
  }

  # CrowdStrike multi-tenant application client ID
  azure_client_id = "0805b105-a007-49b3-b575-14eed38fc1d0"

  # Azure configuration - You can use subscriptions, management groups, or both
  subscription_ids     = ["subscription-id-1", "subscription-id-2"]
  management_group_ids = ["mg-id-1", "mg-id-2"]

  # Azure subscription that will host CrowdStrike infrastructure
  cs_infra_subscription_id = "00000000-0000-0000-0000-000000000000"

  # Optional: CrowdStrike IP addresses for network security
  falcon_ip_addresses = ["1.2.3.4", "5.6.7.8"]

  # Optional: Configure log ingestion settings
  log_ingestion_settings = {
    enabled = true
    activity_log = {
      enabled = true
      existing_eventhub = {
        use = false
        # If use = true, provide existing Event Hub resource ID and consumer group name:
        # eventhub_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing-eventhub/providers/Microsoft.EventHub/namespaces/existing-eventhub-namespace/eventhubs/existing-eventhub"
        # eventhub_consumer_group_name = "$Default"
      }
    }
    entra_id_log = {
      enabled = true
      existing_eventhub = {
        use = false
        # If use = true, provide existing Event Hub resource ID and consumer group name:
        # eventhub_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing-eventhub/providers/Microsoft.EventHub/namespaces/existing-eventhub-namespace/eventhubs/existing-eventhub"
        # eventhub_consumer_group_name = "$Default"
      }
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
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.63.0 |
## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_client_id"></a> [azure\_client\_id](#input\_azure\_client\_id) | Client ID of CrowdStrike's multi-tenant application in Azure. This is typically provided by CrowdStrike and is used to establish the connection between Azure and Falcon Cloud Security. | `string` | `""` | no |
| <a name="input_cs_infra_subscription_id"></a> [cs\_infra\_subscription\_id](#input\_cs\_infra\_subscription\_id) | Azure subscription ID where CrowdStrike infrastructure resources (such as Event Hubs) will be deployed. This subscription must be accessible with the current credentials. | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment identifier used in resource naming and tagging. Examples include 'prod', 'dev', 'test', etc. Limited to 4 alphanumeric characters for compatibility with resource naming restrictions. | `string` | `"prod"` | no |
| <a name="input_falcon_ip_addresses"></a> [falcon\_ip\_addresses](#input\_falcon\_ip\_addresses) | List of CrowdStrike Falcon service IP addresses to be allowed in network security configurations. Refer to https://falcon.crowdstrike.com/documentation/page/re07d589/add-crowdstrike-ip-addresses-to-cloud-provider-allowlists-0 for the IP address list specific to your Falcon cloud region. | `list(string)` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure location (aka region) where global resources (Role definitions, Event Hub, etc.) will be deployed. These tenant-wide resources only need to be created once regardless of how many subscriptions are monitored. | `string` | `"westus"` | no |
| <a name="input_log_ingestion_settings"></a> [log\_ingestion\_settings](#input\_log\_ingestion\_settings) | Configuration settings for log ingestion. Controls whether to enable Azure Activity Logs and Microsoft Entra ID logs collection via Event Hubs, and allows using either newly created Event Hubs or existing ones. | <pre>object({<br/>    enabled = bool<br/>    activity_log = object({<br/>      enabled = bool<br/>      existing_eventhub = object({<br/>        use                          = bool<br/>        eventhub_resource_id         = optional(string)<br/>        eventhub_consumer_group_name = optional(string)<br/>      })<br/>    })<br/>    entra_id_log = object({<br/>      enabled = bool<br/>      existing_eventhub = object({<br/>        use                          = bool<br/>        eventhub_resource_id         = optional(string)<br/>        eventhub_consumer_group_name = optional(string)<br/>      })<br/>    })<br/>  })</pre> | <pre>{<br/>  "activity_log": {<br/>    "enabled": true,<br/>    "existing_eventhub": {<br/>      "eventhub_consumer_group_name": "",<br/>      "eventhub_resource_id": "",<br/>      "use": false<br/>    }<br/>  },<br/>  "enabled": true,<br/>  "entra_id_log": {<br/>    "enabled": true,<br/>    "existing_eventhub": {<br/>      "eventhub_consumer_group_name": "",<br/>      "eventhub_resource_id": "",<br/>      "use": false<br/>    }<br/>  }<br/>}</pre> | no |
| <a name="input_management_group_ids"></a> [management\_group\_ids](#input\_management\_group\_ids) | List of Azure management group IDs to monitor with CrowdStrike Falcon Cloud Security. All subscriptions within these management groups will be automatically discovered and monitored. | `list(string)` | `[]` | no |
| <a name="input_microsoft_graph_permission_ids"></a> [microsoft\_graph\_permission\_ids](#input\_microsoft\_graph\_permission\_ids) | Optional list of Microsoft Graph permission IDs to assign to the service principal. If provided, these will replace the default permissions. Must include 'Application.Read.All' (ID: 9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30) at minimum. | `list(string)` | `null` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix to be added to all created resource names for identification | `string` | `""` | no |
| <a name="input_resource_suffix"></a> [resource\_suffix](#input\_resource\_suffix) | Suffix to be added to all created resource names for identification | `string` | `""` | no |
| <a name="input_subscription_ids"></a> [subscription\_ids](#input\_subscription\_ids) | List of specific Azure subscription IDs to monitor with CrowdStrike Falcon Cloud Security. Use this for targeted monitoring of individual subscriptions. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to be applied to all resources created by this module. Default includes the CrowdStrike vendor tag. | `map(string)` | <pre>{<br/>  "CSTagVendor": "CrowdStrike"<br/>}</pre> | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_active_subscriptions_in_groups"></a> [active\_subscriptions\_in\_groups](#output\_active\_subscriptions\_in\_groups) | Map of Azure management group scopes to active Azure subscriptions discovered within those groups |
| <a name="output_activity_log_eventhub_consumer_group_name"></a> [activity\_log\_eventhub\_consumer\_group\_name](#output\_activity\_log\_eventhub\_consumer\_group\_name) | Consumer group name for Azure Activity Log ingestion via Event Hub |
| <a name="output_activity_log_eventhub_id"></a> [activity\_log\_eventhub\_id](#output\_activity\_log\_eventhub\_id) | Resource ID of the Event Hub used for Azure Activity Log ingestion |
| <a name="output_entra_id_log_eventhub_consumer_group_name"></a> [entra\_id\_log\_eventhub\_consumer\_group\_name](#output\_entra\_id\_log\_eventhub\_consumer\_group\_name) | Consumer group name for Microsoft Entra ID (formerly Azure AD) log ingestion via Event Hub |
| <a name="output_entra_id_log_eventhub_id"></a> [entra\_id\_log\_eventhub\_id](#output\_entra\_id\_log\_eventhub\_id) | Resource ID of the Event Hub used for Microsoft Entra ID (formerly Azure AD) log ingestion |
| <a name="output_management_group_scopes"></a> [management\_group\_scopes](#output\_management\_group\_scopes) | List of Azure management group scopes configured for CrowdStrike Falcon Cloud Security asset inventory |
| <a name="output_service_principal_object_id"></a> [service\_principal\_object\_id](#output\_service\_principal\_object\_id) | Object ID of the CrowdStrike service principal used for Azure resource access |
| <a name="output_subscription_scopes"></a> [subscription\_scopes](#output\_subscription\_scopes) | List of Azure subscription scopes configured for CrowdStrike Falcon Cloud Security asset inventory |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | Azure tenant ID used for CrowdStrike Falcon Cloud Security integration |
<!-- END_TF_DOCS -->
