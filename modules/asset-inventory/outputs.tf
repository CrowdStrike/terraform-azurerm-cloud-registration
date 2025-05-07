output "subscription_scopes" {
  description = "List of Azure subscriptions scopes configured for CrowdStrike asset inventory"
  value       = local.subscription_scopes
}

output "management_group_scopes" {
  description = "List of Azure management group scopes configured for CrowdStrike asset inventory"
  value       = local.management_group_scopes
}

output "app_service_permissions" {
  description = "List of app service permissions granted to the custom app"
  value       = local.app_service_permissions
}

output "active_subscriptions_by_group" {
  description = "Map of management group ID to its enabled subscription IDs"
  value = {
    for mg, subs in module.subscriptions_in_groups.subscriptions_by_group :
    mg => [
      for sub in data.azurerm_subscription.subscriptions-mg : sub.subscription_id if sub.state == "Enabled" && contains(subs, sub.subscription_id)
    ]
  }
}

output "all_active_subscription_ids" {
  description = "List of total active subscription IDs in the specified individual subscriptions and management groups"
  value = toset(
    flatten(concat(var.subscription_ids, [
      for sub in data.azurerm_subscription.subscriptions-mg : sub.subscription_id if sub.state == "Enabled"
    ]))
  )
}