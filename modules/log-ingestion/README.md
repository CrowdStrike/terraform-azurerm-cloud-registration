<!-- BEGIN_TF_DOCS -->
![CrowdStrike Log Ingestion terraform module](https://raw.githubusercontent.com/CrowdStrike/falconpy/main/docs/asset/cs-logo.png)

[![Twitter URL](https://img.shields.io/twitter/url?label=Follow%20%40CrowdStrike&style=social&url=https%3A%2F%2Ftwitter.com%2FCrowdStrike)](https://twitter.com/CrowdStrike)

## Introduction

This Terraform module deploys the required Azure resources to enable CrowdStrike's Real-time Visibility feature in Azure environments. It configures log ingestion for Azure Activity Logs and Microsoft Entra ID (formerly Azure AD) logs via Event Hubs.

## Prerequisites

Before using this module, ensure you have:

1. Azure credentials with sufficient permissions to create Event Hub resources and configure diagnostic settings
2. A CrowdStrike service principal (can be created using the service-principal module)
3. A resource group where the Event Hub resources will be deployed
4. Subscription IDs or management group IDs to monitor

## Implementation Notes

This module performs several key actions:
- Creates Event Hub resources for collecting Azure Activity Logs and Entra ID logs
- Configures diagnostic settings to send logs to the Event Hubs
- Assigns necessary permissions for the CrowdStrike service principal to access the logs
- Optionally deploys a remediation policy to automatically configure diagnostic settings for new subscriptions

The module supports two main log types:
1. **Azure Activity Logs** - Administrative, security, service health, alert, recommendation, policy, autoscale, and resource health logs
2. **Entra ID Logs** - Audit logs, sign-in logs, non-interactive user sign-in logs, service principal sign-in logs, managed identity sign-in logs, and ADFS sign-in logs

## Flexibility Options

This module offers flexibility in deployment:
- Use existing Event Hub resources or create new ones
- Monitor specific subscriptions or entire management groups
- Enable or disable Activity Log and Entra ID log collection independently
- Customize resource naming with prefixes and suffixes
- Deploy remediation policies to ensure consistent log collection across your environment
- Configure network security with IP allowlisting for CrowdStrike services

## Integration with Other Modules

This module is designed to work seamlessly with other CrowdStrike modules:
- Use with the service-principal module to grant the necessary permissions for log access
- Combine with the asset-inventory module for comprehensive cloud security monitoring

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
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.63.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_eventhub.activity_log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub.entra_id_log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub_namespace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace) | resource |
| [azurerm_eventhub_namespace_authorization_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace_authorization_rule) | resource |
| [azurerm_management_group_policy_assignment.activity_log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_policy_assignment) | resource |
| [azurerm_management_group_policy_remediation.activity_log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_policy_remediation) | resource |
| [azurerm_monitor_aad_diagnostic_setting.entra_id_log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_aad_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.activity_log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_policy_definition.activity_log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition) | resource |
| [azurerm_role_assignment.activity_log_event_hub_data_receiver](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.activity_log_policy_lab_azure_eventhubs_data_owner](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.activity_log_policy_lab_services_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.activity_log_policy_monitoring_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.entra_id_eventhub_data_receiver](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_eventhub.activity_log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/eventhub) | data source |
| [azurerm_eventhub.entra_id_log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/eventhub) | data source |
| [azurerm_eventhub_namespace.activity_log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/eventhub_namespace) | data source |
| [azurerm_eventhub_namespace.entra_id_log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/eventhub_namespace) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_activity_log_settings"></a> [activity\_log\_settings](#input\_activity\_log\_settings) | Settings of realtime visibility for activity log | <pre>object({<br/>    enabled = bool<br/>    existing_eventhub = object({<br/>      use                  = bool<br/>      eventhub_resource_id = optional(string)<br/>    })<br/>  })</pre> | <pre>{<br/>  "enabled": true,<br/>  "existing_eventhub": {<br/>    "use": false,<br/>    "eventhub_resource_id": ""<br/>  }<br/>}</pre> | no |
| <a name="input_app_service_principal_id"></a> [app\_service\_principal\_id](#input\_app\_service\_principal\_id) | Service principal ID of Crowdstrike app to which all the roles will be assigned | `string` | n/a | yes |
| <a name="input_cs_infra_subscription_id"></a> [cs\_infra\_subscription\_id](#input\_cs\_infra\_subscription\_id) | Azure subscription ID that will host CrowdStrike infrastructure | `string` | n/a | yes |
| <a name="input_deploy_remediation_policy"></a> [deploy\_remediation\_policy](#input\_deploy\_remediation\_policy) | Deploy a Azure Policy at each the management group to automatically detect and configure activity log diagnostic settings for EventHub in subscriptions where these settings are missing. Be aware that any diagnostic settings deployed by this Azure Policy will not be tracked or managed by Terraform. | `string` | `false` | no |
| <a name="input_entra_id_log_settings"></a> [entra\_id\_log\_settings](#input\_entra\_id\_log\_settings) | Settings of realtime visibility for Entra ID log | <pre>object({<br/>    enabled = bool<br/>    existing_eventhub = object({<br/>      use                  = bool<br/>      eventhub_resource_id = optional(string)<br/>    })<br/>  })</pre> | <pre>{<br/>  "enabled": true,<br/>  "existing_eventhub": {<br/>    "use": false,<br/>    "eventhub_resource_id": ""<br/>  }<br/>}</pre> | no |
| <a name="input_env"></a> [env](#input\_env) | Custom label indicating the environment to be monitored, such as prod, stag or dev. | `string` | `"prod"` | no |
| <a name="input_falcon_ip_addresses"></a> [falcon\_ip\_addresses](#input\_falcon\_ip\_addresses) | List of CrowdStrike Falcon service IP addresses to be allowed in network security configurations. Refer to https://falcon.crowdstrike.com/documentation/page/re07d589/add-crowdstrike-ip-addresses-to-cloud-provider-allowlists-0 for the IP address list specific to your Falcon cloud region. | `list(string)` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure location (aka region) where global resources (Role definitions, Event Hub, etc.) will be deployed. These tenant-wide resources only need to be created once regardless of how many subscriptions are monitored. | `string` | `"westus"` | no |
| <a name="input_management_group_ids"></a> [management\_group\_ids](#input\_management\_group\_ids) | List of management group IDs to monitor | `list(string)` | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name that will host CrowdStrike infrastructure | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | The prefix to be added to the resource name. | `string` | `""` | no |
| <a name="input_resource_suffix"></a> [resource\_suffix](#input\_resource\_suffix) | The suffix to be added to the resource name. | `string` | `""` | no |
| <a name="input_subscription_ids"></a> [subscription\_ids](#input\_subscription\_ids) | List of subscription IDs to monitor | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to all resources | `map(string)` | <pre>{<br/>  "CSTagVendor": "Crowdstrike"<br/>}</pre> | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_activity_log_eventhub_id"></a> [activity\_log\_eventhub\_id](#output\_activity\_log\_eventhub\_id) | Resource ID of the EventHub instance for activity log |
| <a name="output_entra_id_log_eventhub_id"></a> [entra\_id\_log\_eventhub\_id](#output\_entra\_id\_log\_eventhub\_id) | Resource ID of the EventHub instance for Entra ID log |
<!-- END_TF_DOCS -->
