data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}
data "crowdstrike_horizon_azure_client_id" "az" {
  tenant_id = var.tenant_id != "" ? var.tenant_id : data.azurerm_client_config.current.tenant_id
}

locals {
  tenant_id = var.tenant_id != "" ? var.tenant_id : data.azurerm_client_config.current.tenant_id
  object_id = var.object_id != "" ? var.object_id : data.crowdstrike_horizon_azure_client_id.az.object_id

  subscriptions            = toset(var.subscription_ids)
  collection               = var.use_azure_management_group ? toset([local.tenant_id]) : toset(var.subscription_ids)
  subscription_assign_list = [for s in local.subscriptions : "/subscriptions/${s}"]
}

resource "crowdstrike_horizon_azure_account" "accounts" {
  for_each                = local.subscriptions
  tenant_id               = local.tenant_id
  subscription_id         = each.key
  default_subscription_id = each.key == data.azurerm_subscription.current.subscription_id ? true : false
  is_commercial           = var.is_commercial
}

# Reader role
resource "azurerm_role_assignment" "reader" {
  for_each                         = local.collection
  scope                            = var.use_azure_management_group ? "/providers/Microsoft.Management/managementGroups/${each.key}" : "/subscriptions/${each.key}"
  role_definition_id               = "/subscriptions/${each.key}/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
  principal_id                     = local.object_id
  skip_service_principal_aad_check = false

  lifecycle {
    ignore_changes = [
      role_definition_id,
      scope
    ]
  }
}

# Custom App Service reader role
resource "azurerm_role_definition" "custom-appservice-reader" {
  name        = "cs-website-reader-test-tf"
  scope       = var.use_azure_management_group ? "/providers/Microsoft.Management/managementGroups/${local.tenant_id}" : "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
  description = "Crowdstrike Web App Service Custom Role"

  permissions {
    actions = [
      "Microsoft.Web/sites/config/list/Action",
      "Microsoft.Web/sites/Read",
      "Microsoft.Web/sites/config/Read"
    ]
    not_actions = []
  }

  assignable_scopes = var.use_azure_management_group ? ["/providers/Microsoft.Management/managementGroups/${local.tenant_id}"] : local.subscription_assign_list
}

# App Service reader role assignment
resource "azurerm_role_assignment" "appservice-reader" {
  for_each                         = local.collection
  scope                            = var.use_azure_management_group ? "/providers/Microsoft.Management/managementGroups/${each.key}" : "/subscriptions/${each.key}"
  role_definition_id               = azurerm_role_definition.custom-appservice-reader.role_definition_resource_id
  principal_id                     = local.object_id
  skip_service_principal_aad_check = false

  lifecycle {
    ignore_changes = [
      role_definition_id,
      scope
    ]
  }
}

# KeyVault Reader role
resource "azurerm_role_assignment" "keyvault-reader" {
  for_each                         = local.collection
  scope                            = var.use_azure_management_group ? "/providers/Microsoft.Management/managementGroups/${each.key}" : "/subscriptions/${each.key}"
  role_definition_id               = "/subscriptions/${each.key}/providers/Microsoft.Authorization/roleDefinitions/21090545-7ca7-4776-b22c-e363652d74d2"
  principal_id                     = local.object_id
  skip_service_principal_aad_check = false

  lifecycle {
    ignore_changes = [
      role_definition_id,
      scope
    ]
  }
}

# Security Reader role
resource "azurerm_role_assignment" "security-reader" {
  for_each                         = local.collection
  scope                            = var.use_azure_management_group ? "/providers/Microsoft.Management/managementGroups/${each.key}" : "/subscriptions/${each.key}"
  role_definition_id               = "/subscriptions/${each.key}/providers/Microsoft.Authorization/roleDefinitions/39bc4728-0917-49c7-9d2c-d95423bc2eb4"
  principal_id                     = local.object_id
  skip_service_principal_aad_check = false

  lifecycle {
    ignore_changes = [
      role_definition_id,
      scope
    ]
  }
}

# Azure Kubernetes Service RBAC Reader role
resource "azurerm_role_assignment" "kube-rbac-reader" {
  for_each                         = local.collection
  scope                            = var.use_azure_management_group ? "/providers/Microsoft.Management/managementGroups/${each.key}" : "/subscriptions/${each.key}"
  role_definition_id               = "/subscriptions/${each.key}/providers/Microsoft.Authorization/roleDefinitions/7f6c6a51-bcf8-42ba-9220-52d62157d7db"
  principal_id                     = local.object_id
  skip_service_principal_aad_check = false

  lifecycle {
    ignore_changes = [
      role_definition_id,
      scope
    ]
  }
}

