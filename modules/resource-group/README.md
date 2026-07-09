<!-- BEGIN_TF_DOCS -->
![CrowdStrike Resource Group terraform module](https://raw.githubusercontent.com/CrowdStrike/falconpy/main/docs/asset/cs-logo.png)

[![Twitter URL](https://img.shields.io/twitter/url?label=Follow%20%40CrowdStrike&style=social&url=https%3A%2F%2Ftwitter.com%2FCrowdStrike)](https://twitter.com/CrowdStrike)<br/>

## Introduction

This Terraform module deploys a resource group for CrowdStrike infrastructure.

## Usage

```hcl
terraform {
  required_version = ">= 1.9.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "crowdstrike_resource_group" {
  source = "CrowdStrike/cloud-registration/azurerm//modules/resource-group"

  # Optional: Resource group location
  location = "westus"

  # Optional: Resource naming
  resource_prefix = "crwd-"
  resource_suffix = ""
  env             = "prod"
}
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0 |
## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | Environment label (for example, prod, stag, dev) used for resource naming and tagging. Helps distinguish between different deployment environments. Limited to 4 alphanumeric characters for compatibility with resource naming restrictions. | `string` | `"prod"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure location (region) where the resource group is deployed. | `string` | `"westus"` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix to be added to all created resource names for identification. | `string` | `""` | no |
| <a name="input_resource_suffix"></a> [resource\_suffix](#input\_resource\_suffix) | Suffix to be added to all created resource names for identification. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to be applied to all resources created by this module. Default includes the CrowdStrike vendor tag. | `map(string)` | <pre>{<br/>  "CSTagVendor": "CrowdStrike"<br/>}</pre> | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | n/a |
<!-- END_TF_DOCS -->
