output "activity_log_eventhub_namespace_id" {
  description = "Resource ID of the EventHub namespace for activity log"
  value       = local.activityLogEventHubNamespaceId
}

output "activity_log_eventhub_namespace_name" {
  description = "Name of the EventHub namespace for activity log"
  value       = local.activityLogEventHubNamespaceName
}

output "activity_log_eventhub_id" {
  description = "Resource ID of the EventHub instance for activity log"
  value       = local.activityLogEventHubId
}

output "activity_log_eventhub_name" {
  description = "Name of the EventHub instance for activity log"
  value       = local.activityLogEventHubName
}

output "activity_log_eventhub_consumer_group_name" {
  description = "Name of the consumer group of the EventHub for consuming activity log"
  value       = local.activityLogEventHubConsumerGroupName
}

output "entra_id_log_eventhub_namespace_id" {
  description = "Resource ID of the EventHub namespace for Entra ID log"
  value       = local.entraIDLogEventHubNamespaceId
}

output "entra_id_log_eventhub_namespace_name" {
  description = "Name of the EventHub namespace for Entra ID log"
  value       = local.entraIDLogEventHubNamespaceName
}

output "entra_id_log_eventhub_id" {
  description = "Resource ID of the EventHub instance for Entra ID log"
  value       = local.entraIDLogEventHubId
}

output "entra_id_log_eventhub_name" {
  description = "Name of the EventHub instance for Entra ID log"
  value       = local.entraIDLogEventHubName
}

output "entra_id_log_eventhub_consumer_group_name" {
  description = "Name of the consumer group of the EventHub for consuming Entra ID log"
  value       = local.entraIDLogEventHubConsumerGroupName
}
