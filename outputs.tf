output "tenant_id" {
  description = "Azure tenant ID used for CrowdStrike integration"
  value       = local.tenant_id
}

output "service_principal_object_id" {
  description = "Object ID of the CrowdStrike service principal"
  # value       = module.service_principal.object_id
  value = local.app_service_principal_id
}

output "subscription_scopes" {
  description = "List of Azure subscription scopes configured for CrowdStrike Cloud Security"
  value       = module.asset_inventory.subscription_scopes
}

output "management_group_scopes" {
  description = "List of Azure management group scopes configured for CrowdStrike Cloud Security"
  value       = module.asset_inventory.management_group_scopes
}

output "active_subscriptions_in_groups" {
  description = "Map of Azure management group scopes to active Azure subscriptions"
  value       = module.asset_inventory.active_subscriptions_by_group
}

output "activity_log_settings" {
  description = "Settings of activity log ingestion"
  value = {
    eventhub_namespace_id        = module.log_ingestion.activity_log_eventhub_namespace_id
    eventhub_namespace_name      = module.log_ingestion.activity_log_eventhub_namespace_name
    eventhub_name                = module.log_ingestion.activity_log_eventhub_name
    eventhub_id                  = module.log_ingestion.activity_log_eventhub_id
    eventhub_consumer_group_name = module.log_ingestion.activity_log_eventhub_consumer_group_name
  }
}

output "entra_id_log_settings" {
  description = "Settings of Entra ID log ingestion"
  value = {
    eventhub_namespace_id        = module.log_ingestion.entra_id_log_eventhub_namespace_id
    eventhub_namespace_name      = module.log_ingestion.entra_id_log_eventhub_namespace_name
    eventhub_name                = module.log_ingestion.entra_id_log_eventhub_name
    eventhub_id                  = module.log_ingestion.entra_id_log_eventhub_id
    eventhub_consumer_group_name = module.log_ingestion.entra_id_log_eventhub_consumer_group_name
  }
}