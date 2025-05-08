locals {
  policy_definition = jsondecode(file("${path.module}/../../policies/real-time-visibility-detection/policy.json"))
}

resource "azurerm_policy_definition" "activity_log" {
  for_each = local.should_deploy_remediation_policy ? toset(local.management_group_scopes) : []

  name                = "${var.resource_prefix}policy-cslogact${var.resource_suffix}"
  management_group_id = each.value
  display_name        = local.policy_definition.properties.displayName
  description         = local.policy_definition.properties.description
  policy_type         = local.policy_definition.properties.policyType
  metadata            = jsonencode(local.policy_definition.properties.metadata)
  mode                = local.policy_definition.properties.mode
  parameters          = jsonencode(local.policy_definition.properties.parameters)
  policy_rule         = jsonencode(local.policy_definition.properties.policyRule)

  depends_on = [
    azurerm_eventhub.activity_log
  ]
}


resource "azurerm_management_group_policy_assignment" "activity_log" {
  for_each = local.should_deploy_remediation_policy ? toset(local.management_group_scopes) : []

  name     = "pas-cslogact"
  location = var.location
  identity {
    type = "SystemAssigned"
  }
  description          = "Ensures that Activity Log data is send to CrowdStrike for Realtime Visibility assessment."
  display_name         = "CrowdStrike Realtime Visibility"
  policy_definition_id = azurerm_policy_definition.activity_log[each.key].id
  management_group_id  = each.value
  parameters = jsonencode({
    diagnosticSettingName = {
      value = local.activity_log_diagnostic_settings_default_name
    },
    eventHubAuthorizationRuleId = {
      value = azurerm_eventhub_namespace_authorization_rule.this[0].id
    },
    eventHubName = {
      value = azurerm_eventhub.activity_log[0].name
    },
    eventHubSubscriptionId = {
      value = var.cs_infra_subscription_id
    }
  })

  depends_on = [
    azurerm_policy_definition.activity_log
  ]
}

resource "azurerm_role_assignment" "activity_log_policy_monitoring_contributor" {
  for_each = local.should_deploy_remediation_policy ? toset(local.management_group_scopes) : []

  scope                            = each.value
  role_definition_name             = "Monitoring Contributor"
  principal_id                     = azurerm_management_group_policy_assignment.activity_log[each.key].identity[0].principal_id
  skip_service_principal_aad_check = false

  depends_on = [
    azurerm_management_group_policy_assignment.activity_log
  ]
}

resource "azurerm_role_assignment" "activity_log_policy_lab_services_reader" {
  for_each = local.should_deploy_remediation_policy ? toset(local.management_group_scopes) : []

  scope                            = each.value
  role_definition_name             = "Lab Services Reader"
  principal_id                     = azurerm_management_group_policy_assignment.activity_log[each.key].identity[0].principal_id
  skip_service_principal_aad_check = false

  depends_on = [
    azurerm_management_group_policy_assignment.activity_log
  ]
}

resource "azurerm_role_assignment" "activity_log_policy_lab_azure_eventhubs_data_owner" {
  for_each = local.should_deploy_remediation_policy ? toset(local.management_group_scopes) : []

  scope                            = "/subscriptions/${var.cs_infra_subscription_id}"
  role_definition_name             = "Azure Event Hubs Data Owner"
  principal_id                     = azurerm_management_group_policy_assignment.activity_log[each.key].identity[0].principal_id
  skip_service_principal_aad_check = false

  depends_on = [
    azurerm_management_group_policy_assignment.activity_log
  ]
}

resource "azurerm_management_group_policy_remediation" "activity_log" {
  for_each = local.should_deploy_remediation_policy ? toset(local.management_group_scopes) : []

  name                           = "${var.resource_prefix}remediate-cslogact${var.resource_suffix}"
  management_group_id            = each.value
  failure_percentage             = 1
  resource_count                 = 500
  policy_assignment_id           = azurerm_management_group_policy_assignment.activity_log[each.key].id
  policy_definition_reference_id = azurerm_policy_definition.activity_log[each.key].id
  parallel_deployments           = 10

  depends_on = [
    azurerm_policy_definition.activity_log,
    azurerm_management_group_policy_assignment.activity_log
  ]
}
