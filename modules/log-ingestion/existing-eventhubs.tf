data "azurerm_eventhub_namespace" "activity-log" {
  count = !local.shouldDeployEventHubForActivityLog && var.activity_log_settings.enabled ? 1 : 0

  name                = var.activity_log_settings.existing_eventhub.namespace_name
  resource_group_name = var.activity_log_settings.existing_eventhub.resource_group_name
}


data "azurerm_eventhub" "activity-log" {
  count = !local.shouldDeployEventHubForActivityLog && var.activity_log_settings.enabled ? 1 : 0

  name                = var.activity_log_settings.existing_eventhub.name
  namespace_name      = data.azurerm_eventhub_namespace.activity-log[0].name
  resource_group_name = data.azurerm_eventhub_namespace.activity-log[0].resource_group_name
}

data "azurerm_eventhub_namespace" "entra-id-log" {
  count = !local.shouldDeployEventHubForEntraIDLog && var.entra_id_log_settings.enabled ? 1 : 0

  name                = var.entra_id_log_settings.existing_eventhub.namespace_name
  resource_group_name = var.entra_id_log_settings.existing_eventhub.resource_group_name
}


data "azurerm_eventhub" "entra-id-log" {
  count = !local.shouldDeployEventHubForEntraIDLog && var.entra_id_log_settings.enabled ? 1 : 0

  name                = var.entra_id_log_settings.existing_eventhub.name
  namespace_name      = data.azurerm_eventhub_namespace.entra-id-log[0].name
  resource_group_name = data.azurerm_eventhub_namespace.entra-id-log[0].resource_group_name
}