<!-- BEGIN_TF_DOCS -->
![CrowdStrike Log Ingestion Terraform Module for Azure](https://raw.githubusercontent.com/CrowdStrike/falconpy/main/docs/asset/cs-logo.png)

[![Twitter URL](https://img.shields.io/twitter/url?label=Follow%20%40CrowdStrike&style=social&url=https%3A%2F%2Ftwitter.com%2FCrowdStrike)](https://twitter.com/CrowdStrike)

## Introduction

This Terraform module deploys the required Azure resources to enable CrowdStrike's Real-time Visibility feature in Azure environments. It configures log ingestion for Azure Activity Logs and Microsoft Entra ID logs via Event Hubs.

## Prerequisites

Before using this module, ensure you have:

1. Azure credentials with sufficient permissions to create Event Hub resources and configure diagnostic settings
2. A CrowdStrike service principal (can be created using the service-principal module)
3. A resource group where the Event Hub resources will be deployed
4. Subscription IDs or management group IDs to monitor

## Implementation Notes

This module performs several key actions:
- Creates Event Hub resources for collecting Azure Activity Logs and Microsoft Entra ID logs
- Configures diagnostic settings to send logs to the Event Hubs
- Assigns necessary permissions for the CrowdStrike service principal to access the logs

The module supports two main log types:
1. **Azure Activity Logs** - Administrative, security, service health, alert, recommendation, policy, autoscale, and resource health logs
2. **Microsoft Entra ID Logs** - Audit logs, sign-in logs, non-interactive user sign-in logs, service principal sign-in logs, managed identity sign-in logs, and ADFS sign-in logs

## Flexibility Options

This module offers flexibility in deployment:
- Use existing Event Hub resources or create new ones
- Monitor specific subscriptions or entire management groups
- Enable or disable Activity Log and Microsoft Entra ID log collection independently
- Customize resource naming with prefixes and suffixes
- Configure network security with IP allowlisting for CrowdStrike services

## Integration with Other Modules

This module is designed to work seamlessly with other CrowdStrike modules:
- Use with the service-principal module to grant the necessary permissions for log access
- Combine with the asset-inventory module for comprehensive cloud security monitoring

## Usage

```hcl
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
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |
## Resources

| Name | Type |
|------|------|
| [azurerm_eventhub.activity_log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub.entra_id_log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub_namespace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace) | resource |
| [azurerm_eventhub_namespace_authorization_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace_authorization_rule) | resource |
| [azurerm_monitor_aad_diagnostic_setting.entra_id_log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_aad_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.activity_log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_role_assignment.activity_log_event_hub_data_receiver](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.entra_id_eventhub_data_receiver](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [random_string.eventhub_namespace](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_activity_log_settings"></a> [activity\_log\_settings](#input\_activity\_log\_settings) | Configuration settings for Azure Activity Log ingestion | <pre>object({<br/>    enabled = bool<br/>    existing_eventhub = optional(object({<br/>      use                          = bool<br/>      eventhub_resource_id         = optional(string, "")<br/>      eventhub_consumer_group_name = optional(string, "")<br/>    }), { use = false })<br/>  })</pre> | <pre>{<br/>  "enabled": true<br/>}</pre> | no |
| <a name="input_app_service_principal_id"></a> [app\_service\_principal\_id](#input\_app\_service\_principal\_id) | Service principal ID of CrowdStrike app to which all the roles will be assigned for log ingestion | `string` | n/a | yes |
| <a name="input_cs_infra_subscription_id"></a> [cs\_infra\_subscription\_id](#input\_cs\_infra\_subscription\_id) | Azure subscription ID where CrowdStrike infrastructure resources, such as Event Hubs, will be deployed. This subscription must be accessible with the current credentials. | `string` | n/a | yes |
| <a name="input_entra_id_log_settings"></a> [entra\_id\_log\_settings](#input\_entra\_id\_log\_settings) | Configuration settings for Microsoft Entra ID log ingestion | <pre>object({<br/>    enabled = bool<br/>    existing_eventhub = optional(object({<br/>      use                          = bool<br/>      eventhub_resource_id         = optional(string)<br/>      eventhub_consumer_group_name = optional(string)<br/>    }), { use = false })<br/>  })</pre> | <pre>{<br/>  "enabled": true<br/>}</pre> | no |
| <a name="input_env"></a> [env](#input\_env) | Environment label (for example, prod, stag, dev) used for resource naming and tagging. Helps distinguish between different deployment environments. Limited to 4 alphanumeric characters for compatibility with resource naming restrictions. | `string` | `"prod"` | no |
| <a name="input_falcon_ip_addresses"></a> [falcon\_ip\_addresses](#input\_falcon\_ip\_addresses) | List of CrowdStrike Falcon service IP addresses to be allowed in network security configurations for log ingestion. Refer to https://falcon.crowdstrike.com/documentation/page/re07d589/add-crowdstrike-ip-addresses-to-cloud-provider-allowlists-0 for the IP address list specific to your Falcon cloud region. | `list(string)` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure location (region) where global resources such as role definitions and event hub will be deployed. These tenant-wide resources only need to be created once regardless of how many subscriptions are monitored. | `string` | `"westus"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Azure resource group name that will host CrowdStrike log ingestion infrastructure | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix to be added to all created resource names for identification | `string` | `""` | no |
| <a name="input_resource_suffix"></a> [resource\_suffix](#input\_resource\_suffix) | Suffix to be added to all created resource names for identification | `string` | `""` | no |
| <a name="input_subscription_ids"></a> [subscription\_ids](#input\_subscription\_ids) | List of Azure subscription IDs to monitor for log ingestion | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to all resources created by this module | `map(string)` | <pre>{<br/>  "CSTagVendor": "CrowdStrike"<br/>}</pre> | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Tenant ID to monitor | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_activity_log_eventhub_consumer_group_name"></a> [activity\_log\_eventhub\_consumer\_group\_name](#output\_activity\_log\_eventhub\_consumer\_group\_name) | Consumer group name in the EventHub instance dedicated for Activity Log ingestion |
| <a name="output_activity_log_eventhub_id"></a> [activity\_log\_eventhub\_id](#output\_activity\_log\_eventhub\_id) | Resource ID of the Azure EventHub instance configured for Activity Log ingestion |
| <a name="output_entra_id_log_eventhub_consumer_group_name"></a> [entra\_id\_log\_eventhub\_consumer\_group\_name](#output\_entra\_id\_log\_eventhub\_consumer\_group\_name) | Consumer group name in the EventHub instance dedicated for Microsoft Entra ID log ingestion |
| <a name="output_entra_id_log_eventhub_id"></a> [entra\_id\_log\_eventhub\_id](#output\_entra\_id\_log\_eventhub\_id) | Resource ID of the Azure EventHub instance configured for Microsoft Entra ID log ingestion |
<!-- END_TF_DOCS -->
