output "scanning_managed_identity_principal_id" {
  description = "Scanning managed identity principal IDs"
  value       = local.should_deploy_scanning_environment ? module.agentless_scanning_environment[0].scanner_identity_principal_id : var.agentless_scanner_identity_principal_id
}
