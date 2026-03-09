output "scanner_identity_principal_id" {
  description = "Agentless scanning managed identity principal IDs"
  value       = azurerm_user_assigned_identity.scanner.principal_id
}
