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