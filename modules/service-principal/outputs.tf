output "tenant_id" {
  description = "Azure tenant ID"
  value       = local.tenant_id
}

output "client_id" {
  description = "CrowdStrike multi-tenant app client ID"
  value       = local.client_id
}

output "object_id" {
  description = "Service principal object ID in customer tenant"
  value       = azuread_service_principal.sp.object_id
}
