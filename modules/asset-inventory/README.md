<!-- BEGIN_TF_DOCS -->
![CrowdStrike Asset Inventory terraform module](https://raw.githubusercontent.com/CrowdStrike/falconpy/main/docs/asset/cs-logo.png)

[![Twitter URL](https://img.shields.io/twitter/url?label=Follow%20%40CrowdStrike&style=social&url=https%3A%2F%2Ftwitter.com%2FCrowdStrike)](https://twitter.com/CrowdStrike)<br/>

## Introduction

This Terraform module deploys the required Azure resources to enable CrowdStrike's Asset Inventory feature in Azure environments.

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
  subscription_id = "00000000-0000-0000-0000-000000000000" # Replace with your subscription ID that will host CrowdStrike's infrastructure resources
  features {}
}

module "asset_inventory" {
  source = "CrowdStrike/cloud-registration/azurerm//modules/asset-inventory"

  tenant_id = "11111111-1111-1111-1111-111111111111"
  # Specify subscription IDs directly
  subscription_ids = ["subscription-id-1", "subscription-id-2"]
  # AND use management groups
  management_group_ids = ["mg-id-1", "mg-id-2"]

  # Service principal object ID that will be granted permissions
  # This can be obtained from the service-principal module output
  app_service_principal_id = "00000000-0000-0000-0000-000000000000"

  # Optional: Resource naming
  resource_prefix = "cs-"
  resource_suffix = "-prod"
}
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0 |
## Resources

| Name | Type |
|------|------|
| [azurerm_role_assignment.appservice_reader_mg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.appservice_reader_sub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.custom_appservice_reader_mg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_role_definition.custom_appservice_reader_sub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_service_principal_id"></a> [app\_service\_principal\_id](#input\_app\_service\_principal\_id) | Service principal ID of CrowdStrike app to which all the roles will be assigned | `string` | n/a | yes |
| <a name="input_management_group_ids"></a> [management\_group\_ids](#input\_management\_group\_ids) | List of management group IDs to monitor | `list(string)` | `[]` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix to be added to all created resource names for identification. | `string` | `""` | no |
| <a name="input_resource_suffix"></a> [resource\_suffix](#input\_resource\_suffix) | Suffix to be added to all created resource names for identification. | `string` | `""` | no |
| <a name="input_subscription_ids"></a> [subscription\_ids](#input\_subscription\_ids) | List of subscription IDs to monitor | `list(string)` | `[]` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Tenant ID to monitor | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_service_permissions"></a> [app\_service\_permissions](#output\_app\_service\_permissions) | List of app service permissions granted to the custom app |
| <a name="output_management_group_scopes"></a> [management\_group\_scopes](#output\_management\_group\_scopes) | List of Azure management group scopes configured for CrowdStrike asset inventory |
| <a name="output_subscription_scopes"></a> [subscription\_scopes](#output\_subscription\_scopes) | List of Azure subscriptions scopes configured for CrowdStrike asset inventory |
<!-- END_TF_DOCS -->
