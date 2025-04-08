output "crowdstrike_accounts" {
  description = "The created CrowdStrike Horizon Azure accounts"
  value       = crowdstrike_horizon_azure_account.accounts
  sensitive   = true
}

output "tenant_id" {
  description = "Azure tenant ID used for asset inventory"
  value       = local.tenant_id
}

output "object_id" {
  description = "Object ID of the CrowdStrike service principal"
  value       = local.object_id
  sensitive   = true
}

output "subscriptions" {
  description = "List of Azure subscriptions configured for CrowdStrike asset inventory"
  value       = local.subscriptions
}
