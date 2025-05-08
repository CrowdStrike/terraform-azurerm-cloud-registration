output "tenant_id" {
  description = "Azure tenant ID used for CrowdStrike Falcon Cloud Security integration"
  value       = data.azurerm_client_config.current.tenant_id
}

output "service_principal_object_id" {
  description = "Object ID of the CrowdStrike service principal used for Azure resource access"
  value       = module.service_principal.object_id
}

output "subscription_scopes" {
  description = "List of Azure subscription scopes configured for CrowdStrike Falcon Cloud Security asset inventory"
  value       = module.asset_inventory.subscription_scopes
}

output "management_group_scopes" {
  description = "List of Azure management group scopes configured for CrowdStrike Falcon Cloud Security asset inventory"
  value       = module.asset_inventory.management_group_scopes
}

output "active_subscriptions_in_groups" {
  description = "Map of Azure management group scopes to active Azure subscriptions discovered within those groups"
  value       = var.enable_realtime_visibility ? module.deployment_scope.active_subscriptions_by_group : null
}

output "activity_log_eventhub_id" {
  description = "Configuration settings for Azure Activity Log ingestion via Event Hub for real-time visibility"
  value       = var.enable_realtime_visibility && var.realtime_visibility_activity_log_settings.enabled ? module.log_ingestion[0].activity_log_eventhub_id : null
}

output "entra_id_log_eventhub_id" {
  description = "Configuration settings for Microsoft Entra ID (formerly Azure AD) log ingestion via Event Hub for real-time visibility"
  value       = var.enable_realtime_visibility && var.realtime_visibility_entra_id_log_settings.enabled ? module.log_ingestion[0].entra_id_log_eventhub_id : null
}
