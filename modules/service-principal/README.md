<!-- BEGIN_TF_DOCS -->
# CrowdStrike Service Principal Terraform Module for Azure

![CrowdStrike Service Principal Terraform Module for Azure](https://raw.githubusercontent.com/CrowdStrike/falconpy/main/docs/asset/cs-logo.png)

[![Twitter URL](https://img.shields.io/twitter/url?label=Follow%20%40CrowdStrike&style=social&url=https%3A%2F%2Ftwitter.com%2FCrowdStrike)](https://twitter.com/CrowdStrike)<br/>

## Introduction

This Terraform module creates and configures the necessary Azure service principal for CrowdStrike's cloud security services. 
It handles the creation of a service principal in your Azure tenant using CrowdStrike's multi-tenant application and assigns the required Microsoft Graph API permissions to enable comprehensive security monitoring.

## Usage

This module requires Azure Active Directory permissions to create service principals and assign API permissions. The user or service principal running Terraform must have sufficient privileges to perform these operations.
### Prerequisites

- Azure credentials with Global Administrator or Application Administrator permissions
- CrowdStrike's multi-tenant application client ID
- Azure CLI installed if using management group functionality

### Example Configuration

```hcl
module "service_principal" {
  source = "CrowdStrike/cloud-registration/azure//modules/service-principal"
  
  azure_client_id = "0805b105-a007-49b3-b575-14eed38fc1d0"
  
  # Optionally customize Microsoft Graph app roles
  # entra_id_permissions = [
  #   "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30", # Application.Read.All
  #   "98830695-27a2-44f7-8c18-0c3ebc9698f6"  # GroupMember.Read.All
  # ]
}
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >= 1.6.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.63.0 |

## Resources

| Name | Type |
|------|------|
| [azuread_app_role_assignment.entra_id_permissions](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_service_principal.sp](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_service_principal.msgraph](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |

## Inputs

| Name                                                                                               | Description                                                                                                 | Type           | Default           | Required |
|----------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|----------------|-------------------|:--------:|
| <a name="input_azure_client_id"></a> [azure\_client\_id](#input\_azure\_client\_id)                | Client ID of CrowdStrike's multi-tenant app (optional - will be retrieved from CrowdStrike if not provided) | `string`       | `""`              |    no    |
| <a name="input_entra_id_permissions"></a> [app\_roles](#input\_app\_roles)                         | List of Microsoft Graph app role IDs to assign to the service principal                                     | `list(string)` | See default value |    no    |
| <a name="input_env"></a> [env](#input\_env)                                                        | Custom label indicating the environment to be monitored, such as `prod`, `stag`, `dev`, etc.                | `string`       | `prod`            |    no    |
| <a name="input_region"></a> [region](#input\_region)                                               | Azure region for the resources deployed in this solution.                                                   | `string`       | `prod`            |    no    |
| <a name="input_resource_name_prefix"></a> [resource\_name\_prefix](#input\_resource\_name\_prefix) | The prefix to be added to the resource name                                                                 | `string`       | `""`              |    no    |
| <a name="input_resource_name_suffix"></a> [resource\_name\_suffix](#input\_resource\_name\_suffix) | The suffix to be added to the resource name                                                                 | `string`       | `""`              |    no    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                     | Tags to be applied to all resources                                                                         | map(string)    | `{}`              |    no    |

## Outputs

| Name                                                              | Description                                    |
|-------------------------------------------------------------------|------------------------------------------------|
| <a name="output_object_id"></a> [object\_id](#output\_object\_id) | Service principal object ID in customer tenant |

<!-- END_TF_DOCS -->
