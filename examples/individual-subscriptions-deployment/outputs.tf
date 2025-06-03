output "tenant_id" {
  description = "Azure tenant ID used for CrowdStrike Falcon Cloud Security integration"
  value       = module.crowdstrike_azure_registration.tenant_id
}

output "service_principal_object_id" {
  description = "Object ID of the CrowdStrike service principal used for Azure resource access"
  value       = module.crowdstrike_azure_registration.service_principal_object_id
}

output "subscription_scopes" {
  description = "List of Azure subscription scopes configured for CrowdStrike Falcon Cloud Security asset inventory"
  value       = module.crowdstrike_azure_registration.subscription_scopes
}

output "activity_log_eventhub_id" {
  description = "Resource ID of the Event Hub used for Azure Activity Log ingestion"
  value       = module.crowdstrike_azure_registration.activity_log_eventhub_id
}

output "activity_log_eventhub_consumer_group_name" {
  description = "Consumer group name for Azure Activity Log ingestion via Event Hub"
  value       = module.crowdstrike_azure_registration.activity_log_eventhub_consumer_group_name
}

output "entra_id_log_eventhub_id" {
  description = "Resource ID of the Event Hub used for Microsoft Entra ID (formerly Azure AD) log ingestion"
  value       = module.crowdstrike_azure_registration.entra_id_log_eventhub_id
}

output "entra_id_log_eventhub_consumer_group_name" {
  description = "Consumer group name for Microsoft Entra ID (formerly Azure AD) log ingestion via Event Hub"
  value       = module.crowdstrike_azure_registration.entra_id_log_eventhub_consumer_group_name
}
