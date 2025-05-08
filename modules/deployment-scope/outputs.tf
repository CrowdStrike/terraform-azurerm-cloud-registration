output "active_subscriptions_by_group" {
  description = "Map of management group ID to its enabled subscription IDs"
  value = {
    for mg, subs in local.subs_by_groups :
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