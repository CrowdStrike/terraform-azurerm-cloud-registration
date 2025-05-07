resource "azurerm_monitor_diagnostic_setting" "activity-log" {
  for_each = local.shouldDeployEventHubForActivityLog ? toset(local.subscription_scopes) : []

  name                           = local.activityLogDiagnosticSettingsDefaultName
  target_resource_id             = each.value
  eventhub_name                  = module.new_eventhub[0].activity_log_eventhub_name
  eventhub_authorization_rule_id = module.new_eventhub[0].eventhub_namespace_authorization_rule_id
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
    module.new_eventhub,
    module.existing_activity_log_eventhub
  ]
}

resource "azurerm_monitor_aad_diagnostic_setting" "entra-id-log" {
  count = local.shouldDeployEventHubForEntraIDLog ? 1 : 0

  name                           = local.entraIDLogDiagnosticSettingsDefaultName
  eventhub_name                  = module.new_eventhub[0].entra_id_log_eventhub_name
  eventhub_authorization_rule_id = module.new_eventhub[0].eventhub_namespace_authorization_rule_id
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
    module.new_eventhub,
    module.existing_entra_id_log_eventhub
  ]
}