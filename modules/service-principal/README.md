<!-- BEGIN_TF_DOCS -->
![CrowdStrike Registration with aws role terraform module](https://raw.githubusercontent.com/CrowdStrike/falconpy/main/docs/asset/cs-logo.png)

[![Twitter URL](https://img.shields.io/twitter/url?label=Follow%20%40CrowdStrike&style=social&url=https%3A%2F%2Ftwitter.com%2FCrowdStrike)](https://twitter.com/CrowdStrike)<br/>

## Introduction

This Terraform module creates and configures the necessary Azure service principal for CrowdStrike's cloud security services. It handles the registration of your Azure tenant with CrowdStrike and assigns the required Microsoft Graph API permissions to enable comprehensive security monitoring.

The module supports both standard Azure Commercial and Azure Government environments.
The module would create a new service principal in your tenant using CrowdStrike's multi-tenant application.
When using Azure Management Groups, this module can enable automatic discovery of all subscriptions within your tenant, simplifying deployment across large Azure environments.

## Usage

This module requires Azure Active Directory permissions to create service principals and assign API permissions. The user or service principal running Terraform must have sufficient privileges to perform these operations.

### Prerequisites

- Azure credentials with Global Administrator or Application Administrator permissions
- CrowdStrike Falcon API credentials
- Azure CLI installed if using management group functionality

### Example Configuration

```hcl
module "service_principal" {
  source = "CrowdStrike/cloud-registration/azure//modules/service-principal"

  # Use Azure Management Group for automatic subscription discovery
  use_azure_management_group = true
  default_subscription_id    = "subscription-id-1"
  
  # For GovCloud environments
  # is_commercial = true
}
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >= 1.6.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.63.0 |
| <a name="provider_crowdstrike"></a> [crowdstrike](#provider\_crowdstrike) | >= 0.2.0 |

## Resources

| Name | Type |
|------|------|
| [azuread_app_role_assignment.app_roles](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_service_principal.sp](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [crowdstrike_horizon_azure_account.account](https://registry.terraform.io/providers/crowdstrike/crowdstrike/latest/docs/resources/horizon_azure_account) | resource |
| [crowdstrike_horizon_azure_client_id.cs-client](https://registry.terraform.io/providers/crowdstrike/crowdstrike/latest/docs/resources/horizon_azure_client_id) | resource |
| [crowdstrike_horizon_azure_management_group.management_group](https://registry.terraform.io/providers/crowdstrike/crowdstrike/latest/docs/resources/horizon_azure_management_group) | resource |
| [azuread_client_config.client](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azuread_service_principal.msgraph](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [crowdstrike_horizon_azure_client_id.az](https://registry.terraform.io/providers/crowdstrike/crowdstrike/latest/docs/data-sources/horizon_azure_client_id) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_client_id"></a> [azure\_client\_id](#input\_azure\_client\_id) | Client ID of CrowdStrike's multi-tenant app (optional - will be retrieved from CrowdStrike if not provided) | `string` | `""` | no |
| <a name="input_use_azure_management_group"></a> [use\_azure\_management\_group](#input\_use\_azure\_management\_group) | Set to `true` to enable automatic subscription discovery | `bool` | `false` | no |
| <a name="input_default_subscription_id"></a> [default\_subscription\_id](#input\_default\_subscription\_id) | Default subscription ID, required when use_azure_management_group = true | `string` | `""` | no |
| <a name="input_is_commercial"></a> [is\_commercial](#input\_is\_commercial) | Is the account commercial? Only applicable when in GovCloud Falcon environment | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | Azure tenant ID |
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | CrowdStrike multi-tenant app client ID |
| <a name="output_object_id"></a> [object\_id](#output\_object\_id) | Service principal object ID in customer tenant |

<!-- END_TF_DOCS -->
