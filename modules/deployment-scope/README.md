<!-- BEGIN_TF_DOCS -->
![CrowdStrike Deployment Scope terraform module](https://raw.githubusercontent.com/CrowdStrike/falconpy/main/docs/asset/cs-logo.png)

[![Twitter URL](https://img.shields.io/twitter/url?label=Follow%20%40CrowdStrike&style=social&url=https%3A%2F%2Ftwitter.com%2FCrowdStrike)](https://twitter.com/CrowdStrike)

## Introduction

This Terraform module helps define the deployment scope for CrowdStrike's cloud security services in Azure environments. It resolves management groups to their constituent subscriptions and provides outputs that can be used by other modules to target specific Azure subscriptions.

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

module "deployment_scope" {
  source = "CrowdStrike/cloud-registration/azure//modules/deployment-scope"

  # Specify subscription IDs directly
  subscription_ids = ["subscription-id-1", "subscription-id-2"]

  # AND/OR use management groups
  management_group_ids = ["mg-id-1", "mg-id-2"]
}
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.63.0 |
## Resources

| Name | Type |
|------|------|
| [azurerm_management_group.groups](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/management_group) | data source |
| [azurerm_subscription.subscriptions_mg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_management_group_ids"></a> [management\_group\_ids](#input\_management\_group\_ids) | List of management group IDs to monitor | `list(string)` | `[]` | no |
| <a name="input_subscription_ids"></a> [subscription\_ids](#input\_subscription\_ids) | List of subscription IDs to monitor | `list(string)` | `[]` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_active_subscriptions_by_group"></a> [active\_subscriptions\_by\_group](#output\_active\_subscriptions\_by\_group) | Map of management group ID to its enabled subscription IDs |
| <a name="output_all_active_subscription_ids"></a> [all\_active\_subscription\_ids](#output\_all\_active\_subscription\_ids) | List of total active subscription IDs in the specified individual subscriptions and management groups |
<!-- END_TF_DOCS -->
