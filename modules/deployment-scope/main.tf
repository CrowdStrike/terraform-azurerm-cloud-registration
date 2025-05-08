# Discover active subscriptions under the specified management groups
# module "subscriptions_in_groups" {
#   source = "./modules/resolve-management-group/"
#
#   management_group_ids = var.management_group_ids
# }

data "azurerm_management_group" "groups" {
  for_each = toset(var.management_group_ids)
  name     = each.value
}

locals {
  groups_to_subs = distinct(flatten([for mg in data.azurerm_management_group.groups : mg.all_subscription_ids]))
  subs_by_groups = {
    for mg in data.azurerm_management_group.groups : mg.name => mg.all_subscription_ids
  }
}

data "azurerm_subscription" "subscriptions_mg" {
  for_each        = toset(local.groups_to_subs)
  subscription_id = each.value
}
