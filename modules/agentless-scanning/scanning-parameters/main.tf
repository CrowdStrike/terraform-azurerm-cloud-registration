locals {
  environment = var.env == "" ? "" : "-${var.env}"

  parameter_definitions = {
    deploymentVersion                         = "1.1.0+terraform.1"
    scanningPrincipalId                       = jsonencode(var.agentless_scanning_principal_id)
    falconClientId                            = jsonencode(var.falcon_client_id)
    enableDspm                                = jsonencode(var.enable_dspm)
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
}
