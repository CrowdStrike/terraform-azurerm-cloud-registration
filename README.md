<!-- BEGIN_TF_DOCS -->
![CrowdStrike Registration terraform module](https://raw.githubusercontent.com/CrowdStrike/falconpy/main/docs/asset/cs-logo.png)

[![Twitter URL](https://img.shields.io/twitter/url?label=Follow%20%40CrowdStrike&style=social&url=https%3A%2F%2Ftwitter.com%2FCrowdStrike)](https://twitter.com/CrowdStrike)<br/>

# Azure Falcon Cloud Security Terraform Module

This Terraform module enables registration and configuration of Azure accounts with CrowdStrike's Falcon Cloud Security.

Key features:
- Service Principal
- Asset Inventory

## Pre-requisites
### Generate API Keys

CrowdStrike API keys are required to use this module. It is highly recommended that you create a dedicated API client with only the required scopes.

1. In the CrowdStrike console, navigate to **Support and resources** > **API Clients & Keys**. Click **Add new API Client**.
2. Add the required scopes for your deployment:

<table>
    <tr>
        <th>Option</th>
        <th>Scope Name</th>
        <th>Permission</th>
    </tr>
    <tr>
        <td rowspan="2">Automated account registration</td>
        <td>CSPM registration</td>
        <td><strong>Read</strong> and <strong>Write</strong></td>
    </tr>
</table>

3. Click **Add** to create the API client. The next screen will display the API **CLIENT ID**, **SECRET**, and **BASE URL**. You will need all three for the next step.

    <details><summary>picture</summary>
    <p>

    ![api-client-keys](https://github.com/CrowdStrike/aws-ssm-distributor/blob/main/official-package/assets/api-client-keys.png)

    </p>
    </details>

> [!NOTE]
> This page is only shown once. Make sure you copy **CLIENT ID**, **SECRET**, and **BASE URL** to a secure location.

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
    crowdstrike = {
      source  = "cs-dev-cloudconnect-templates.s3.amazonaws.com/crowdstrike/crowdstrike"
      version = ">= 0.2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {
}

provider "crowdstrike" {
  client_id     = var.cs_client_id
  client_secret = var.cs_client_secret
}

module "crowdstrike_azure_registration" {
  source = "CrowdStrike/cloud-registration/azure"

  # CrowdStrike API credentials
  cs_client_id     = var.cs_client_id
  cs_client_secret = var.cs_client_secret
  
  # Azure configuration - Option 1: Specific subscriptions
  subscription_ids = ["subscription-id-1", "subscription-id-2"]
  
  # OR Option 2: Management group for automatic subscription discovery
  # use_azure_management_group = true
  # default_subscription_id = "primary-subscription-id"
}

```

## Providers

| Name | Version |
|------|---------|
| [azuread](https://registry.terraform.io/providers/hashicorp/azuread) | >= 1.6.0 |
| [azurerm](https://registry.terraform.io/providers/hashicorp/azurerm) | >= 3.63.0 |
| [crowdstrike](https://registry.terraform.io/providers/crowdstrike/crowdstrike) | >= 0.2.0 |

## Resources

| Name | Type |
|------|------|
| [null_resource.validate_inputs](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [crowdstrike_horizon_azure_client_id.target](https://registry.terraform.io/providers/crowdstrike/crowdstrike/latest/docs/data-sources/horizon_azure_client_id) | data source |

## Modules

| Name | Source | Description |
|------|--------|-------------|
| [service_principal](./modules/service-principal/) | ./modules/service-principal/ | Creates and configures the service principal for CrowdStrike integration |
| [asset_inventory](./modules/asset-inventory/) | ./modules/asset-inventory/ | Configures Azure asset inventory for CrowdStrike |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cs_client_id | CrowdStrike API client ID | `string` | n/a | yes |
| cs_client_secret | CrowdStrike API client secret | `string` | n/a | yes |
| tenant_id | Azure tenant ID. If not provided, will use the current Azure context | `string` | `""` | no |
| azure_client_id | Client ID of CrowdStrike's multi-tenant app (will be retrieved from CrowdStrike if not provided) | `string` | n/a | yes |
| use_azure_management_group | Set to true to enable management group level access | `bool` | `false` | no |
| default_subscription_id | Default subscription ID, required when use_azure_management_group = true | `string` | `""` | no |
| subscription_ids | List of Azure subscription IDs to monitor | `list(string)` | `[]` | no |
| is_commercial | Is the account commercial? Only applicable when you're in the GovCloud Falcon environment | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| tenant_id | Azure tenant ID used for CrowdStrike integration |
| service_principal_object_id | Object ID of the CrowdStrike service principal |
| configured_subscriptions | List of Azure subscriptions configured for CrowdStrike |

<!-- END_TF_DOCS -->
