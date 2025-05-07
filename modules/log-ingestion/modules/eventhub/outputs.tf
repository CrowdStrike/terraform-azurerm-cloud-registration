output "eventhub_namespace_id" {
  description = "Resource ID of the EventHub namespace"
  value       = azurerm_eventhub_namespace.this.id
}

output "eventhub_namespace_name" {
  description = "Name of the EventHub namespace"
  value       = azurerm_eventhub_namespace.this.name
}

output "activity_log_eventhub_id" {
  description = "Resource ID of the EventHub instance for activity log"
  value       = local.shouldDeployEventHubForActivityLog ? azurerm_eventhub.activity-log[0].id : ""
}

output "activity_log_eventhub_name" {
  description = "Name of the EventHub instance for activity log"
  value       = local.shouldDeployEventHubForActivityLog ? azurerm_eventhub.activity-log[0].name : ""
}

output "entra_id_log_eventhub_id" {
  description = "Resource ID of the EventHub instance for Entra ID log"
  value       = local.shouldDeployEventHubForEntraIDLog ? azurerm_eventhub.entra-id-log[0].id : ""
}

output "entra_id_log_eventhub_name" {
  description = "Name of the EventHub instance for Entra ID log"
  value       = local.shouldDeployEventHubForEntraIDLog ? azurerm_eventhub.entra-id-log[0].name : ""
}

output "eventhub_namespace_authorization_rule_id" {
  description = "Resource ID of the EventHub namespace authorization rule"
  value       = azurerm_eventhub_namespace_authorization_rule.this.id
}