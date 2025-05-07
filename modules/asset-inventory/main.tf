data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

locals {
  tenant_id               = var.tenant_id != "" ? var.tenant_id : data.azurerm_client_config.current.tenant_id
  subscription_scopes     = [for id in var.subscription_ids : "/subscriptions/${id}"]
  management_group_scopes = [for id in var.management_group_ids : "/providers/Microsoft.Management/managementGroups/${id}"]
  all_scopes              = concat(local.subscription_scopes, local.management_group_scopes)

  app_service_permissions = [
    "Microsoft.Web/sites/config/list/Action",
    "Microsoft.Web/sites/Read",
    "Microsoft.Web/sites/config/Read"
  ]
}

# Only create this if we have subscription scopes
resource "azurerm_role_definition" "custom-appservice-reader-sub" {
  count       = length(local.subscription_scopes) > 0 ? 1 : 0
  name        = "cs-website-reader-sub"
  scope       = local.subscription_scopes[0]
  description = "Crowdstrike Web App Service Custom Role"
  permissions {
    actions     = local.app_service_permissions
    not_actions = []
  }

  assignable_scopes = local.subscription_scopes
}

resource "azurerm_role_assignment" "appservice-reader-sub" {
  for_each                         = length(local.subscription_scopes) > 0 ? toset(local.subscription_scopes) : []
  scope                            = each.value
  role_definition_id               = azurerm_role_definition.custom-appservice-reader-sub[0].role_definition_resource_id
  principal_id                     = var.app_service_principal_id
  skip_service_principal_aad_check = false

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}

resource "azurerm_role_definition" "custom-appservice-reader-mg" {
  for_each    = { for id in var.management_group_ids : "/providers/Microsoft.Management/managementGroups/${id}" => id }
  name        = "cs-website-reader-${each.value}"
  scope       = each.key
  description = "Crowdstrike Web App Service Custom Role"

  permissions {
    actions     = local.app_service_permissions
    not_actions = []
  }

  assignable_scopes = [each.key]
}

resource "azurerm_role_assignment" "appservice-reader-mg" {
  for_each                         = { for id in var.management_group_ids : "/providers/Microsoft.Management/managementGroups/${id}" => id }
  scope                            = each.key
  role_definition_id               = azurerm_role_definition.custom-appservice-reader-mg[each.key].role_definition_resource_id
  principal_id                     = var.app_service_principal_id
  skip_service_principal_aad_check = false
}

# Reader role assignments for all scopes
resource "azurerm_role_assignment" "reader" {
  for_each                         = toset(local.all_scopes)
  scope                            = each.value
  role_definition_name             = "Reader"
  principal_id                     = var.app_service_principal_id
  skip_service_principal_aad_check = false
}

# Discover active subscriptions under the specified management groups
module "subscriptions_in_groups" {
  source = "./modules/resolve-deployment-scope/"

  management_group_ids = var.management_group_ids
}

data "azurerm_subscription" "subscriptions-mg" {
  for_each        = toset(module.subscriptions_in_groups.all_subscription_ids)
  subscription_id = each.value
}