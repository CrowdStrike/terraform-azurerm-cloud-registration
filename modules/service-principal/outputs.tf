output "object_id" {
  description = "Service principal object ID in customer tenant"
  value       = azuread_service_principal.sp.object_id
}
