output "activity_log_eventhub_id" {
  description = "Resource ID of the Azure EventHub instance configured for Activity Log ingestion"
  value       = local.activity_log_eventhub_id
}

output "activity_log_eventhub_consumer_group_name" {
  description = "Consumer group name in the EventHub instance dedicated for Activity Log ingestion"
  value       = local.activity_log_eventhub_consumer_group_name
}

output "entra_id_log_eventhub_id" {
  description = "Resource ID of the Azure EventHub instance configured for Microsoft Entra ID log ingestion"
  value       = local.entra_id_log_eventhub_id
}

output "entra_id_log_eventhub_consumer_group_name" {
  description = "Consumer group name in the EventHub instance dedicated for Microsoft Entra ID log ingestion"
  value       = local.entra_id_log_eventhub_consumer_group_name
}
