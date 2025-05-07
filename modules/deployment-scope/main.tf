# Discover active subscriptions under the specified management groups
module "subscriptions_in_groups" {
  source = "./modules/resolve-management-group/"

  management_group_ids = var.management_group_ids
}

data "azurerm_subscription" "subscriptions-mg" {
  for_each        = toset(module.subscriptions_in_groups.all_subscription_ids)
  subscription_id = each.value
}