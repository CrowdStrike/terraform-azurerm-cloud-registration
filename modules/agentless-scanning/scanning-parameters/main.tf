locals {
  environment = var.env == "" ? "" : "-${var.env}"

  # Same keys as the Bicep template writes, so the policy parameter has one shape for both
  dspm_access_scopes_policy_keys = {
    blob_storage     = "blobStorage"
    table_storage    = "tableStorage"
    azure_files      = "azureFiles"
    virtual_machines = "virtualMachines"
    azure_sql        = "azureSql"
  }

  # Stored as the customer set it, without defaults or enable_dspm applied
  dspm_access_scopes = {
    for resource_type, enabled in var.input_dspm_access_scopes : local.dspm_access_scopes_policy_keys[resource_type] => enabled
  }

  parameter_definitions = {
    deploymentVersion                         = jsonencode("1.5.0+terraform.1")
    scanningPrincipalId                       = jsonencode(var.agentless_scanning_principal_id)
    falconClientId                            = jsonencode(var.falcon_client_id)
    enableDspm                                = jsonencode(var.enable_dspm)
    dspmAccessScopes                          = jsonencode(local.dspm_access_scopes)
    enableVulnerabilityScanning               = jsonencode(var.enable_vulnerability_scanning)
    agentlessScanningLocations                = jsonencode(var.agentless_scanning_locations)
    agentlessScanningLocationsPerSubscription = jsonencode(var.agentless_scanning_locations_per_subscription)
    agentlessScanningHostSubscriptionId       = jsonencode(var.agentless_scanning_host_subscription_id)
    agentlessScanningDeployNatGateway         = jsonencode(var.agentless_scanning_deploy_nat_gateway)
    agentlessScanningCustomVnetConfiguration  = jsonencode(var.agentless_scanning_custom_vnet_configuration)
    resourceNamePrefix                        = jsonencode(var.resource_prefix)
    resourceNameSuffix                        = jsonencode(var.resource_suffix)
    env                                       = jsonencode(var.env)
    tags                                      = jsonencode(var.tags)
  }
}

# Policy definition to store agentless scanning parameters
resource "azurerm_policy_definition" "scanning_parameters" {
  name         = "${var.resource_prefix}policy-csscanning-parameters${local.environment}${var.resource_suffix}"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "CrowdStrike Agentless Scanning Parameters"

  metadata = jsonencode({
    category = "CrowdStrike"
    version  = "1.0.0"
  })

  parameters = jsonencode({
    for key, value in local.parameter_definitions : key => {
      type         = "String"
      defaultValue = value
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        for key, _ in local.parameter_definitions : {
          value  = "[parameters('${key}')]"
          exists = "true"
        }
      ]
    }
    then = {
      effect = "disabled"
    }
  })

  lifecycle {
    precondition {
      condition     = !var.enable_dspm || anytrue(values(var.resolved_dspm_access_scopes))
      error_message = "DSPM is enabled but every 'dspm_access_scopes' ('input_dspm_access_scopes' in the agentless-scanning module) resource type is false. Set at least one resource type to true, or set 'enable_dspm' ('input_enable_dspm') to false."
    }
  }
}
