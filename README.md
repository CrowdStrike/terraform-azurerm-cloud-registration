<!-- BEGIN_TF_DOCS -->
![CrowdStrike Registration terraform module](https://raw.githubusercontent.com/CrowdStrike/falconpy/main/docs/asset/cs-logo.png)

[![Twitter URL](https://img.shields.io/twitter/url?label=Follow%20%40CrowdStrike&style=social&url=https%3A%2F%2Ftwitter.com%2FCrowdStrike)](https://twitter.com/CrowdStrike)<br/>

# Azure Falcon Cloud Security Terraform Module

This Terraform module enables registration and configuration of Azure accounts with CrowdStrike's Falcon Cloud Security.

Key features:
- Service Principal creation with Microsoft Graph permissions
- Asset Inventory configuration for both subscription and management group scopes

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
  
  # Azure configuration - Option 1: Specific subscriptions
  subscription_ids = ["subscription-id-1", "subscription-id-2"]
  
  # OR Option 2: Management groups
  # management_group_ids = ["mg-id-1", "mg-id-2"]
  
  # Optional: Customize Microsoft Graph app roles
  # custom_app_roles = [
  #   "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30", # Application.Read.All
  #   "98830695-27a2-44f7-8c18-0c3ebc9698f6"  # GroupMember.Read.All
  # ]
}
```

## Providers

| Name | Version |
|------|---------|
| [azuread](https://registry.terraform.io/providers/hashicorp/azuread) | >= 1.6.0 |
| [azurerm](https://registry.terraform.io/providers/hashicorp/azurerm) | >= 3.63.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Modules

| Name | Source | Description |
|------|--------|-------------|
| [service_principal](./modules/service-principal/) | ./modules/service-principal/ | Creates and configures the service principal with Microsoft Graph permissions |
| [asset_inventory](./modules/asset-inventory/) | ./modules/asset-inventory/ | Configures Azure asset inventory with custom roles for both subscription and management group scopes |

## Inputs

| Name                              | Description                                                                                                                                                                                                                                 | Type           | Default               | Required |
|-----------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|-----------------------|:--------:|
| tenant_id                         | Azure tenant ID (optional - will be retrieved from current client config if not provided)                                                                                                                                                   | `string`       | `""`                  |    no    |
| management_group_ids              | List of management group IDs to monitor                                                                                                                                                                                                     | `list(string)` | `[]`                  |    no    |
| subscription_ids                  | List of subscription IDs to monitor                                                                                                                                                                                                         | `list(string)` | `[]`                  |    no    |
| cs_infrastructure_subscription_id | Azure subscription ID that will host CrowdStrike infrastructure                                                                                                                                                                             | `string`       | `""`                  |   yes    |
| falcon_cid                        | Falcon CID                                                                                                                                                                                                                                  | `string`       | `""`                  |   yes    |
| falcon_client_id                  | Client ID for the Falcon API                                                                                                                                                                                                                | `string`       | `""`                  |   yes    |
| falcon_client_secret              | Client secret for the Falcon API                                                                                                                                                                                                            | `string`       | `""`                  |   yes    |
| falcon_url                        | Falcon cloud API url                                                                                                                                                                                                                        | `string`       | `api.crowdstrike.com` |    no    |
| falcon_ip_addresses               | List of IPv4 addresses of Crowdstrike Falcon service. Please refer to https://falcon.crowdstrike.com/documentation/page/re07d589/add-crowdstrike-ip-addresses-to-cloud-provider-allowlists-0 for the IP address list of your Falcon region. | `list(string)` | `[]`                  |    no    |
| azure_client_id                   | Client ID of CrowdStrike's multi-tenant app                                                                                                                                                                                                 | `string`       | `""`                  |   yes    |
| custom_app_roles                  | Optional list of Microsoft Graph app role IDs to assign to the service principal                                                                                                                                                            | `list(string)` | `null`                |    no    |
| env                               | Custom label indicating the environment to be monitored, such as `prod`, `stag`, `dev`, etc.                                                                                                                                                | `string`       | `prod`                |    no    |
| region                            | Azure region for the resources deployed in this solution                                                                                                                                                                                    | `string`       | `westus`              |    no    |
| resource_name_prefix              | The prefix to be added to the resource name                                                                                                                                                                                                 | `string`       | `""`                  |    no    |
| resource_name_suffix              | The suffix to be added to the resource name                                                                                                                                                                                                 | `string`       | `""`                  |    no    |
| tags                              | Tags to be applied to all resources                                                                                                                                                                                                         | `map(string)`  | `{}`                  |    no    |


## Outputs

| Name                        | Description                                                                      |
|-----------------------------|----------------------------------------------------------------------------------|
| tenant_id                   | Azure tenant ID used for CrowdStrike integration                                 |
| service_principal_object_id | Object ID of the CrowdStrike service principal                                   |
| subscription_scopes         | List of Azure subscription scopes configured for CrowdStrike asset inventory     |
| management_group_scopes     | List of Azure management group scopes configured for CrowdStrike asset inventory |
| subscription_role_name      | The name of the custom role for subscriptions                                    |
| management_group_role_names | List of custom role names for management groups                                  |

<!-- END_TF_DOCS -->
