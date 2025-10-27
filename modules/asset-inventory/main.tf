locals {
  subscription_scopes     = [for id in var.subscription_ids : "/subscriptions/${id}"]
  management_group_scopes = [for id in var.management_group_ids : "/providers/Microsoft.Management/managementGroups/${id}"]
  all_scopes              = concat(local.subscription_scopes, local.management_group_scopes)

  app_service_permissions = [
    "Microsoft.Web/sites/config/list/Action",
    "Microsoft.Web/sites/publish/action",
    "Microsoft.Web/sites/Read",
    "Microsoft.Web/sites/config/Read"
  ]
}

# Only create this if we have subscription scopes
resource "azurerm_role_definition" "custom_appservice_reader_sub" {
  count       = length(local.subscription_scopes) > 0 && !contains(var.management_group_ids, var.tenant_id) ? 1 : 0
  name        = "${var.resource_prefix}role-csreader-sub${var.resource_suffix}"
  scope       = local.subscription_scopes[0]
  description = "CrowdStrike Web App Service Custom Role"
  permissions {
    actions     = local.app_service_permissions
    not_actions = []
  }

  assignable_scopes = local.subscription_scopes
}

resource "azurerm_role_assignment" "appservice_reader_sub" {
  for_each                         = length(local.subscription_scopes) > 0 && !contains(var.management_group_ids, var.tenant_id) ? toset(local.subscription_scopes) : []
  scope                            = each.value
  role_definition_id               = azurerm_role_definition.custom_appservice_reader_sub[0].role_definition_resource_id
  principal_id                     = var.app_service_principal_id
  skip_service_principal_aad_check = false

  lifecycle {
    ignore_changes = [
      role_definition_id,
    ]
  }
}

resource "azurerm_role_definition" "custom_appservice_reader_mg" {
  for_each    = { for id in var.management_group_ids : "/providers/Microsoft.Management/managementGroups/${id}" => id }
  name        = "${var.resource_prefix}role-csreader-${each.value}${var.resource_suffix}"
  scope       = each.key
  description = "CrowdStrike Web App Service Custom Role"

  permissions {
    actions     = local.app_service_permissions
    not_actions = []
  }

  assignable_scopes = [each.key]
}

resource "azurerm_role_assignment" "appservice_reader_mg" {
  for_each                         = { for id in var.management_group_ids : "/providers/Microsoft.Management/managementGroups/${id}" => id }
  scope                            = each.key
  role_definition_id               = azurerm_role_definition.custom_appservice_reader_mg[each.key].role_definition_resource_id
  principal_id                     = var.app_service_principal_id
  skip_service_principal_aad_check = false
}

# Reader role assignments for all scopes
resource "azurerm_role_assignment" "reader" {
  for_each                         = contains(var.management_group_ids, var.tenant_id) ? toset(local.management_group_scopes) : toset(local.all_scopes)
  scope                            = each.value
  role_definition_name             = "Reader"
  principal_id                     = var.app_service_principal_id
  skip_service_principal_aad_check = false
}
