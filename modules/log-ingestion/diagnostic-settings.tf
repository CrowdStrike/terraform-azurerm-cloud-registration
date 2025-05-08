resource "azurerm_monitor_diagnostic_setting" "activity_log" {
  for_each = local.should_deploy_eventhub_for_activity_log ? toset(local.subscription_scopes) : []

  name                           = local.activity_log_diagnostic_settings_default_name
  target_resource_id             = each.value
  eventhub_name                  = azurerm_eventhub.activity_log[0].name
  eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.this[0].id
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
    azurerm_eventhub.activity_log
  ]
}

resource "azurerm_monitor_aad_diagnostic_setting" "entra_id_log" {
  count = local.should_deploy_eventhub_for_entra_id_log ? 1 : 0

  name                           = local.entra_id_log_diagnostic_settings_default_name
  eventhub_name                  = azurerm_eventhub.entra_id_log[0].id
  eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.this[0].id
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
    azurerm_eventhub.entra_id_log
  ]
}
