output "tenant_id" {
  description = "Azure tenant ID used for CrowdStrike integration"
  value       = local.tenant_id
}

output "service_principal_object_id" {
  description = "Object ID of the CrowdStrike service principal"
  value       = module.service_principal.object_id
}

output "subscription_scopes" {
  description = "List of Azure subscription scopes configured for CrowdStrike asset inventory"
  value       = module.asset_inventory.subscription_scopes
}

output "management_group_scopes" {
  description = "List of Azure management group scopes configured for CrowdStrike asset inventory"
  value       = module.asset_inventory.management_group_scopes
}