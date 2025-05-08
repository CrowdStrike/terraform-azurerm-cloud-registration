resource "azurerm_monitor_diagnostic_setting" "activity-log" {
  for_each = local.shouldDeployEventHubForActivityLog ? toset(local.subscription_scopes) : []

  name                           = local.activityLogDiagnosticSettingsDefaultName
  target_resource_id             = each.value
  eventhub_name                  = local.activityLogEventHubName
  eventhub_authorization_rule_id = local.activityLogEventHubAuthorizationRuleId
  enabled_log {
    category = "Administrative"
  }
  enabled_log {
    category = "Security"
  }
  enabled_log {
    category = "ServiceHealth"
  }
  enabled_log {
    category = "Alert"
  }
  enabled_log {
    category = "Recommendation"
  }
  enabled_log {
    category = "Policy"
  }
  enabled_log {
    category = "Autoscale"
  }
  enabled_log {
    category = "ResourceHealth"
  }

  depends_on = [
    azurerm_eventhub.activity-log
  ]
}

resource "azurerm_monitor_aad_diagnostic_setting" "entra-id-log" {
  count = local.shouldDeployEventHubForEntraIDLog ? 1 : 0

  name                           = local.entraIDLogDiagnosticSettingsDefaultName
  eventhub_name                  = local.entraIDLogEventHubName
  eventhub_authorization_rule_id = local.entraIDLogEventHubAuthorizationRuleId
  enabled_log {
    category = "AuditLogs"
  }
  enabled_log {
    category = "SignInLogs"
  }
  enabled_log {
    category = "NonInteractiveUserSignInLogs"
  }
  enabled_log {
    category = "ServicePrincipalSignInLogs"
  }
  enabled_log {
    category = "ManagedIdentitySignInLogs"
  }
  enabled_log {
    category = "ADFSSignInLogs"
  }
  depends_on = [
    azurerm_eventhub.entra-id-log
  ]
}