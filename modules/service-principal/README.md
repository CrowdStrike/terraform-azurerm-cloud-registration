<!-- BEGIN_TF_DOCS -->
![CrowdStrike Service Principal Terraform Module for Azure](https://raw.githubusercontent.com/CrowdStrike/falconpy/main/docs/asset/cs-logo.png)

[![Twitter URL](https://img.shields.io/twitter/url?label=Follow%20%40CrowdStrike&style=social&url=https%3A%2F%2Ftwitter.com%2FCrowdStrike)](https://twitter.com/CrowdStrike)

## Introduction

This Terraform module creates and configures the necessary Azure service principal for CrowdStrike's cloud security services. It handles the creation of a service principal in your Azure tenant using CrowdStrike's multi-tenant application and assigns the required Microsoft Graph API permissions to enable comprehensive security monitoring.

## Usage

```hcl
terraform {
  required_version = ">= 1.9.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 1.6.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

# Create service principal
module "service_principal" {
  source = "CrowdStrike/cloud-registration/azure//modules/service-principal"

  # Client ID of CrowdStrike's multi-tenant app
  azure_client_id = "0805b105-a007-49b3-b575-14eed38fc1d0"

  # Customize Microsoft Graph app roles
  microsoft_graph_permission_ids = [
    "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30", # Application.Read.All (Role)
    "98830695-27a2-44f7-8c18-0c3ebc9698f6", # GroupMember.Read.All (Role)
    "246dd0d5-5bd0-4def-940b-0421030a5b68", # Policy.Read.All (Role)
    "230c1aed-a721-4c5d-9cb4-a90514e508ef", # Reports.Read.All (Role)
    "483bed4a-2ad3-4361-a73b-c83ccdbdc53c", # RoleManagement.Read.Directory (Role)
    "df021288-bdef-4463-88db-98f22de89214"  # User.Read.All (Role)
  ]
}
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >= 1.6.0 |
## Resources

| Name | Type |
|------|------|
| [azuread_app_role_assignment.microsoft_graph_permissions](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_service_principal.sp](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_service_principal.msgraph](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_client_id"></a> [azure\_client\_id](#input\_azure\_client\_id) | Client ID of CrowdStrike's multi-tenant app | `string` | n/a | yes |
| <a name="input_microsoft_graph_permission_ids"></a> [microsoft\_graph\_permission\_ids](#input\_microsoft\_graph\_permission\_ids) | List of Microsoft Graph app role IDs to assign to the service principal | `list(string)` | `[]` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_object_id"></a> [object\_id](#output\_object\_id) | Service principal object ID in customer tenant |
<!-- END_TF_DOCS -->
