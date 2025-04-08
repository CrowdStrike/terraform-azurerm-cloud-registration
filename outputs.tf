output "tenant_id" {
  description = "Azure tenant ID used for CrowdStrike integration"
  value       = module.service_principal.tenant_id
}

output "service_principal_object_id" {
  description = "Object ID of the CrowdStrike service principal"
  value       = module.service_principal.object_id
  # sensitive   = true
}

output "configured_subscriptions" {
  description = "List of Azure subscriptions configured for CrowdStrike"
  value       = module.asset_inventory.subscriptions
}