<!-- BEGIN_TF_DOCS -->
![CrowdStrike Agentless Scanning Environment terraform module](https://raw.githubusercontent.com/CrowdStrike/falconpy/main/docs/asset/cs-logo.png)

[![Twitter URL](https://img.shields.io/twitter/url?label=Follow%20%40CrowdStrike&style=social&url=https%3A%2F%2Ftwitter.com%2FCrowdStrike)](https://twitter.com/CrowdStrike)<br/>

## Introduction

This Terraform module deploys the required Azure resources to enable CrowdStrike's Agentless Scanning feature in Azure
environments.

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

module "crowdstrike_agentless_scanning" {
  source = "CrowdStrike/cloud-registration/azurerm//modules/agentless-scanning"

  # Provision new resource group for agentless scanning
  deploy_resource_group = true

  # Principal ID of CrowdStrike app for agentless scanning orchestration
  agentless_scanning_principal_id = "00000000-0000-0000-0000-000000000000"

  # Locations to enable for agentless scanning
  agentless_scanning_locations = ["westus"]

  # Optional: specify if NAT gateway should be deployed
  agentless_scanning_deploy_nat_gateway = true

  # Optional: KeyVault IP allowlist rules
  key_vault_allowed_ip_rules = ["127.0.0.1/32"]

  # Falcon API credentials to store for scanner use
  falcon_client_id     = "00000000000000000000000000000000"
  falcon_client_secret = "0000000000000000000000000000000000000000"

  # Optional: Resource naming
  resource_prefix = "cs-"
  resource_suffix = ""
  env             = "dev"

  # Optional: Custom tags
  tags = {
    "Developer" : "me"
  }
}
```

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.42.0 |
## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_agentless_scanner_identity_principal_id"></a> [agentless\_scanner\_identity\_principal\_id](#input\_agentless\_scanner\_identity\_principal\_id) | Optional Azure agentless scanning host scanner managed identity ID. Required when 'scanning\_host\_subscription\_id' is set. | `string` | `""` | no |
| <a name="input_agentless_scanning_custom_vnet_configuration"></a> [agentless\_scanning\_custom\_vnet\_configuration](#input\_agentless\_scanning\_custom\_vnet\_configuration) | Per-region custom VNet configuration for agentless scanning. Keys are Azure region names; values contain scanners\_subnet\_id and clones\_subnet\_id. | <pre>map(object({<br/>    scanners_subnet_id = string<br/>    clones_subnet_id   = string<br/>  }))</pre> | `{}` | no |
| <a name="input_agentless_scanning_deploy_nat_gateway"></a> [agentless\_scanning\_deploy\_nat\_gateway](#input\_agentless\_scanning\_deploy\_nat\_gateway) | Indicates Agentless Scanning environment will be deployed with NAT Gateway. | `bool` | `true` | no |
| <a name="input_agentless_scanning_host_subscription_id"></a> [agentless\_scanning\_host\_subscription\_id](#input\_agentless\_scanning\_host\_subscription\_id) | If specified deploy as target subscription. | `string` | `""` | no |
| <a name="input_agentless_scanning_locations"></a> [agentless\_scanning\_locations](#input\_agentless\_scanning\_locations) | List of Azure locations (regions) where scanning environment will be deployed. | `list(string)` | `[]` | no |
| <a name="input_agentless_scanning_principal_id"></a> [agentless\_scanning\_principal\_id](#input\_agentless\_scanning\_principal\_id) | Principal ID of the CrowdStrike application registered in Entra ID. This ID is used for role assignments and access control. | `string` | n/a | yes |
| <a name="input_deploy_resource_group"></a> [deploy\_resource\_group](#input\_deploy\_resource\_group) | Indicates Agentless Scanning environment will be deployed with a new resource group. | `bool` | `true` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment label (for example, prod, stag, dev) used for resource naming and tagging. Helps distinguish between different deployment environments. Limited to 4 alphanumeric characters for compatibility with resource naming restrictions. | `string` | `"prod"` | no |
| <a name="input_falcon_client_id"></a> [falcon\_client\_id](#input\_falcon\_client\_id) | Falcon API client ID. | `string` | n/a | yes |
| <a name="input_falcon_client_secret"></a> [falcon\_client\_secret](#input\_falcon\_client\_secret) | Falcon API client secret. | `string` | n/a | yes |
| <a name="input_host_mg_id"></a> [host\_mg\_id](#input\_host\_mg\_id) | Management group ID that the host subscription belongs to. Used to automatically wire MG-scoped role definitions for the host subscription. | `string` | `""` | no |
| <a name="input_input_agentless_scanning_locations_per_subscription"></a> [input\_agentless\_scanning\_locations\_per\_subscription](#input\_input\_agentless\_scanning\_locations\_per\_subscription) | Map of Azure subscription IDs to lists of locations (regions) where agentless scanning will be deployed per subscription. | `map(list(string))` | `{}` | no |
| <a name="input_input_enable_dspm"></a> [input\_enable\_dspm](#input\_input\_enable\_dspm) | Controls whether to enable DSPM (Data Security Posture Management). Stored in scanning parameters policy. | `bool` | `true` | no |
| <a name="input_key_vault_allowed_ip_rules"></a> [key\_vault\_allowed\_ip\_rules](#input\_key\_vault\_allowed\_ip\_rules) | Allowed IP rules (IPs or CIDR blocks) for restricting Key Vault access. If empty all network access will be allowed. | `list(string)` | `[]` | no |
| <a name="input_management_group_scopes"></a> [management\_group\_scopes](#input\_management\_group\_scopes) | Set of management group IDs to create MG-scoped role definitions for. When non-empty, role definitions are created at MG scope instead of per-subscription. | `set(string)` | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group where CrowdStrike infrastructure resources will be deployed. | `string` | `""` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix to be added to all created resource names for identification. | `string` | `""` | no |
| <a name="input_resource_suffix"></a> [resource\_suffix](#input\_resource\_suffix) | Suffix to be added to all created resource names for identification. | `string` | `""` | no |
| <a name="input_scanning_role_definition_ids"></a> [scanning\_role\_definition\_ids](#input\_scanning\_role\_definition\_ids) | MG-scoped role definition resource IDs. When provided, skip creating per-subscription role definitions and only create assignments using these external IDs. | <pre>object({<br/>    subscription_access  = string<br/>    rg_access            = string<br/>    rg_access_target     = string<br/>    subscription_scanner = string<br/>    custom_vnet_subnet   = string<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to be applied to all resources created by this module. Default includes the CrowdStrike vendor tag. | `map(string)` | <pre>{<br/>  "CSTagVendor": "CrowdStrike"<br/>}</pre> | no |
## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_scanning_managed_identity_principal_id"></a> [scanning\_managed\_identity\_principal\_id](#output\_scanning\_managed\_identity\_principal\_id) | Scanning managed identity principal IDs |
| <a name="output_scanning_role_definition_ids_by_mg"></a> [scanning\_role\_definition\_ids\_by\_mg](#output\_scanning\_role\_definition\_ids\_by\_mg) | Map of management group ID to MG-scoped scanning role definition resource IDs. |
<!-- END_TF_DOCS -->