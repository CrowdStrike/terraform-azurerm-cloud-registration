<!-- BEGIN_TF_DOCS -->
# CrowdStrike Asset Inventory Terraform Module for Azure

![CrowdStrike Asset Inventory terraform module](https://raw.githubusercontent.com/CrowdStrike/falconpy/main/docs/asset/cs-logo.png)

[![Twitter URL](https://img.shields.io/twitter/url?label=Follow%20%40CrowdStrike&style=social&url=https%3A%2F%2Ftwitter.com%2FCrowdStrike)](https://twitter.com/CrowdStrike)

## Introduction

This Terraform module deploys the required Azure resources to enable CrowdStrike's Asset Inventory feature in Azure environments.

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

module "asset_inventory" {
  source = "CrowdStrike/cloud-registration/azure//modules/asset-inventory"

  # Specify subscription IDs directly
  subscription_ids = ["subscription-id-1", "subscription-id-2"]
  # AND use management groups
  management_group_ids = ["mg-id-1", "mg-id-2"]
  
  # Service principal object ID that will be granted permissions
  object_id = "00000000-0000-0000-0000-000000000000"
}
```

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.63.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_role_assignment.reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.appservice-reader-sub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.appservice-reader-mg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.custom-appservice-reader-sub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_role_definition.custom-appservice-reader-mg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name                     | Description                                                                                  | Type         | Default  | Required |
|--------------------------|----------------------------------------------------------------------------------------------|--------------|----------|:--------:|
| tenant_id                | Used to create a graph dependency, not needed when running the module independently          | string       | ""       |    no    |
| subscription_ids         | List of subscription IDs                                                                     | list(string) | []       |    no    |
| management_group_ids     | List of management group IDs                                                                 | list(string) | []       |    no    |
| cs_infra_subscription_id | Azure subscription ID that will host CrowdStrike infrastructure                              | `string`     | `""`     |   yes    |
| object_id                | Service principal object_id to which all the roles will be assigned                          | string       | ""       |    no    |
| env                      | Custom label indicating the environment to be monitored, such as `prod`, `stag`, `dev`, etc. | `string`     | `prod`   |    no    |
| region                   | Azure region for the resources deployed in this solution                                     | `string`     | `westus` |    no    |
| resource_prefix          | The prefix to be added to the resource name                                                  | `string`     | `""`     |    no    |
| resource_suffix          | The suffix to be added to the resource name                                                  | `string`     | `""`     |    no    |
| tags                     | Tags to be applied to all resources                                                          | map(string)  | {}       |    no    |

## Outputs

| Name                          | Description                                                                                           |
|-------------------------------|-------------------------------------------------------------------------------------------------------|
| subscription_scopes           | List of Azure subscriptions scopes configured for CrowdStrike asset inventory                         |
| management_group_scopes       | List of Azure management group scopes configured for CrowdStrike asset inventory                      |
| app_service_permissions       | List of app service permissions granted to the custom app                                             |
| subscription_role_name        | The name of the custom role for subscriptions                                                         |
| management_group_role_names   | List of custom role names for management groups                                                       |
| active_subscriptions_by_group | Map of management group ID to its enabled subscription IDs                                            |
| all_active_subscription_ids   | List of total active subscription IDs in the specified individual subscriptions and management groups |

<!-- END_TF_DOCS -->
