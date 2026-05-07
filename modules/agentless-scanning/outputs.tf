output "scanning_managed_identity_principal_id" {
  description = "Scanning managed identity principal IDs"
  value       = local.should_deploy_scanning_environment ? module.agentless_scanning_environment[0].scanner_identity_principal_id : var.agentless_scanner_identity_principal_id
}

output "scanning_role_definition_ids_by_mg" {
  description = "Map of management group ID to MG-scoped scanning role definition resource IDs."
  value = {
    for mg_id, mod in module.agentless_scanning_role_definitions_mg : mg_id => mod.role_definition_ids
  }
}
