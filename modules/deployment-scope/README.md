<!-- BEGIN_TF_DOCS -->
# CrowdStrike Deployment Scope Terraform Module for Azure

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

| Name    | Version   |
|---------|-----------|
| azurerm | >= 3.63.0 |

## Resources

| Name                                                                                                                                     | Type        |
|------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [azurerm_subscription.subscriptions-mg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Modules

| Name                    | Source                              | Description                                          |
|-------------------------|-------------------------------------|------------------------------------------------------|
| subscriptions_in_groups | ./modules/resolve-management-group/ | Resolves management groups to their subscription IDs |

## Inputs

| Name                 | Description                             | Type         | Default | Required |
|----------------------|-----------------------------------------|--------------|---------|:--------:|
| subscription_ids     | List of subscription IDs to monitor     | list(string) | []      |    no    |
| management_group_ids | List of management group IDs to monitor | list(string) | []      |    no    |

## Outputs

| Name                          | Description                                                                                           |
|-------------------------------|-------------------------------------------------------------------------------------------------------|
| active_subscriptions_by_group | Map of management group ID to its enabled subscription IDs                                            |
| all_active_subscription_ids   | List of total active subscription IDs in the specified individual subscriptions and management groups |

<!-- END_TF_DOCS -->
