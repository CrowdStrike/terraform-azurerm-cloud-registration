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
  value       = local.should_deploy_log_ingestion ? module.deployment_scope.active_subscriptions_by_group : null
}

output "activity_log_eventhub_id" {
  description = "Resource ID of the Event Hub used for Azure Activity Log ingestion"
  value       = local.should_deploy_log_ingestion && var.log_ingestion_settings.activity_log.enabled ? module.log_ingestion[0].activity_log_eventhub_id : null
}

output "activity_log_eventhub_consumer_group_name" {
  description = "Consumer group name for Azure Activity Log ingestion via Event Hub"
  value       = local.should_deploy_log_ingestion && var.log_ingestion_settings.activity_log.enabled ? module.log_ingestion[0].activity_log_eventhub_consumer_group_name : null
}

output "entra_id_log_eventhub_id" {
  description = "Resource ID of the Event Hub used for Microsoft Entra ID (formerly Azure AD) log ingestion"
  value       = local.should_deploy_log_ingestion && var.log_ingestion_settings.entra_id_log.enabled ? module.log_ingestion[0].entra_id_log_eventhub_id : null
}

output "entra_id_log_eventhub_consumer_group_name" {
  description = "Consumer group name for Microsoft Entra ID (formerly Azure AD) log ingestion via Event Hub"
  value       = local.should_deploy_log_ingestion && var.log_ingestion_settings.entra_id_log.enabled ? module.log_ingestion[0].entra_id_log_eventhub_consumer_group_name : null
}
