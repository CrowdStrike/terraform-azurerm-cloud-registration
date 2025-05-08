output "activity_log_eventhub_id" {
  description = "Resource ID of the EventHub instance for activity log"
  value       = local.activity_log_eventhub_id
}

output "entra_id_log_eventhub_id" {
  description = "Resource ID of the EventHub instance for Entra ID log"
  value       = local.entra_id_log_eventhub_id
}
