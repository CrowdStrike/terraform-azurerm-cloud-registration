output "eventhub_namespace_id" {
  description = "Resource ID of the EventHub namespace"
  value       = data.azurerm_eventhub_namespace.this.id
}

output "eventhub_namespace_name" {
  description = "Name of the EventHub namespace"
  value       = data.azurerm_eventhub_namespace.this.name
}

output "eventhub_id" {
  description = "Resource ID of the EventHub instance"
  value       = data.azurerm_eventhub.this.id
}

output "eventhub_name" {
  description = "Name of the EventHub instance"
  value       = data.azurerm_eventhub.this.name
}