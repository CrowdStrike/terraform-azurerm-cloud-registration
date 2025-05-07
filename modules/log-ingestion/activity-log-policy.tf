locals {
  policy_definition = jsondecode(file("${path.root}/policies/real-time-visibility-detection/policy.json"))
}

resource "azurerm_policy_definition" "activity-log" {
  for_each = local.shouldDeployRemediationPolicy ? toset(local.management_group_scopes) : []

  name                = "${local.prefix}policy-cslogact${local.suffix}"
  management_group_id = each.value
  display_name        = local.policy_definition.properties.displayName
  description         = local.policy_definition.properties.description
  policy_type         = local.policy_definition.properties.policyType
  metadata            = jsonencode(local.policy_definition.properties.metadata)
  mode                = local.policy_definition.properties.mode
  parameters          = jsonencode(local.policy_definition.properties.parameters)
  policy_rule         = jsonencode(local.policy_definition.properties.policyRule)

  depends_on = [
    module.new_eventhub,
    module.existing_activity_log_eventhub
  ]
}


resource "azurerm_management_group_policy_assignment" "activity-log" {
  for_each = local.shouldDeployRemediationPolicy ? toset(local.management_group_scopes) : []

  name     = "${local.prefix}pas-cslogact${local.suffix}"
  location = var.region
  identity {
    type = "SystemAssigned"
  }
  description          = "Ensures that Activity Log data is send to CrowdStrike for Real Time Visibility and Detection assessment."
  display_name         = "CrowdStrike Real Time Visibility and Detection"
  policy_definition_id = azurerm_policy_definition.activity-log[each.key].id
  management_group_id  = each.value
  parameters = jsonencode({
    diagnosticSettingName = {
      value = local.activityLogDiagnosticSettingsDefaultName
    },
    eventHubAuthorizationRuleId = {
      value = local.activityLogEventHubAuthorizationRuleId
    },
    eventHubName = {
      value = local.activityLogEventHubName
    },
    eventHubSubscriptionId = {
      value = local.activityLogEventHubSubscriptionId
    }
  })

  depends_on = [
    azurerm_policy_definition.activity-log
  ]
}

resource "azurerm_role_assignment" "activity-log-policy-monitoring-contributor" {
  for_each = local.shouldDeployRemediationPolicy ? toset(local.management_group_scopes) : []

  scope                            = each.value
  role_definition_name             = "Monitoring Contributor"
  principal_id                     = azurerm_management_group_policy_assignment.activity-log[each.key].identity[0].principal_id
  skip_service_principal_aad_check = false

  depends_on = [
    azurerm_management_group_policy_assignment.activity-log
  ]
}

resource "azurerm_role_assignment" "activity-log-policy-lab-services-reader" {
  for_each = local.shouldDeployRemediationPolicy ? toset(local.management_group_scopes) : []

  scope                            = each.value
  role_definition_name             = "Lab Services Reader"
  principal_id                     = azurerm_management_group_policy_assignment.activity-log[each.key].identity[0].principal_id
  skip_service_principal_aad_check = false

  depends_on = [
    azurerm_management_group_policy_assignment.activity-log
  ]
}

resource "azurerm_role_assignment" "activity-log-policy-lab-azure-eventhubs-data-owner" {
  for_each = local.shouldDeployRemediationPolicy ? toset(local.management_group_scopes) : []

  scope                            = "/subscriptions/${local.activityLogEventHubSubscriptionId}"
  role_definition_name             = "Azure Event Hubs Data Owner"
  principal_id                     = azurerm_management_group_policy_assignment.activity-log[each.key].identity[0].principal_id
  skip_service_principal_aad_check = false

  depends_on = [
    azurerm_management_group_policy_assignment.activity-log
  ]
}

resource "azurerm_role_assignment" "activity-log-policy-lab-azure-eventhubs-data-sender" {
  for_each = local.shouldDeployRemediationPolicy ? toset(local.management_group_scopes) : []

  scope                            = "/subscriptions/${local.activityLogEventHubSubscriptionId}"
  role_definition_name             = "Azure Event Hubs Data Sender"
  principal_id                     = azurerm_management_group_policy_assignment.activity-log[each.key].identity[0].principal_id
  skip_service_principal_aad_check = false

  depends_on = [
    azurerm_management_group_policy_assignment.activity-log
  ]
}

resource "azurerm_management_group_policy_remediation" "activity-log" {
  for_each = local.shouldDeployRemediationPolicy ? toset(local.management_group_scopes) : []

  name                           = "${local.prefix}remediate-cslogact${local.suffix}"
  management_group_id            = each.value
  failure_percentage             = 1
  resource_count                 = 500
  policy_assignment_id           = azurerm_management_group_policy_assignment.activity-log[each.key].id
  policy_definition_reference_id = azurerm_policy_definition.activity-log[each.key].id
  parallel_deployments           = 10

  depends_on = [
    azurerm_policy_definition.activity-log,
    azurerm_management_group_policy_assignment.activity-log
  ]
}