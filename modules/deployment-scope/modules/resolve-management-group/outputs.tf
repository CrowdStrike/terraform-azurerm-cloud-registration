output "all_subscription_ids" {
  description = "List of subscription IDs under the specified management groups"
  value       = distinct(flatten([for mg in data.azurerm_management_group.groups : mg.all_subscription_ids]))
}

output "subscriptions_by_group" {
  description = "Map of management group ID to its enabled subscription IDs"
  value = {
    for mg in data.azurerm_management_group.groups : mg.name => mg.all_subscription_ids
  }
}