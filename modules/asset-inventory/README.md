# CrowdStrike Asset Inventory Terraform Module for Azure

![CrowdStrike Asset Inventory terraform module](https://raw.githubusercontent.com/CrowdStrike/falconpy/main/docs/asset/cs-logo.png)

[![Twitter URL](https://img.shields.io/twitter/url?label=Follow%20%40CrowdStrike&style=social&url=https%3A%2F%2Ftwitter.com%2FCrowdStrike)](https://twitter.com/CrowdStrike)

## Introduction

This Terraform module deploys the required Azure resources to enable CrowdStrike's Asset Inventory feature in Azure environments. The solution helps organizations track both managed and unmanaged Azure assets, enabling better cloud security posture management.

## Usage

```hcl
terraform {
  required_version = ">= 0.15"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.63.0"
    }
    crowdstrike = {
      source  = "cs-dev-cloudconnect-templates.s3.amazonaws.com/crowdstrike/crowdstrike"
      version = ">= 0.2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "crowdstrike" {
  client_id     = var.falcon_client_id
  client_secret = var.falcon_client_secret
}

module "asset_inventory" {
  source = "CrowdStrike/cloud-registration/azure//modules/asset-inventory"

  subscription_ids = ["subscription-id-1", "subscription-id-2"]
  # OR use management group for automatic subscription discovery
  # use_azure_management_group = true
}
```

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.63.0 |
| crowdstrike | >= 0.2.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_role_assignment.reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.appservice-reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.keyvault-reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.security-reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.kube-rbac-reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.custom-appservice-reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [crowdstrike_horizon_azure_account.accounts](https://registry.terraform.io/providers/crowdstrike/crowdstrike/latest/docs/resources/horizon_azure_account) | resource |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [crowdstrike_horizon_azure_client_id.az](https://registry.terraform.io/providers/crowdstrike/crowdstrike/latest/docs/data-sources/horizon_azure_client_id) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| subscription_ids | List of subscription IDs to include | list(string) | [] | no |
| is_commercial | Is the account commercial? Only applicable when you're in the GovCloud Falcon environment | bool | false | no |
| use_azure_management_group | Set to `true` to enable automatic subscription discovery | bool | false | no |
| tenant_id | Used to create a graph dependency, not needed when running the module independently | string | "" | no |
| object_id | Used to create a graph dependency, not needed when running the module independently | string | "" | no |

## Outputs

| Name | Description |
|------|-------------|
| crowdstrike_accounts | The created CrowdStrike Horizon Azure accounts |
| tenant_id | Azure tenant ID used for asset inventory |
| object_id | Object ID of the CrowdStrike service principal |
| subscriptions | List of Azure subscriptions configured for CrowdStrike asset inventory |

<!-- END_TF_DOCS -->
