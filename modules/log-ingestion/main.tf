locals {
  activity_log_diagnostic_settings_default_name = "${var.resource_prefix}diag-cslogact${var.resource_suffix}"
  entra_id_log_diagnostic_settings_default_name = "${var.resource_prefix}diag-cslogentid${var.resource_suffix}"
  subscription_scopes                           = [for id in var.subscription_ids : "/subscriptions/${id}"]
  management_group_scopes                       = [for id in var.management_group_ids : "/providers/Microsoft.Management/managementGroups/${id}"]
  should_deploy_eventhub_for_activity_log       = var.activity_log_settings.enabled && !var.activity_log_settings.existing_eventhub.use
  should_deploy_eventhub_for_entra_id_log       = var.entra_id_log_settings.enabled && !var.entra_id_log_settings.existing_eventhub.use
  should_deploy_eventhub_namespace              = local.should_deploy_eventhub_for_activity_log || local.should_deploy_eventhub_for_entra_id_log
  should_deploy_remediation_policy              = local.should_deploy_eventhub_for_activity_log && var.deploy_remediation_policy
  env                                           = var.env == "" ? "" : "-${var.env}"
}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}


resource "azurerm_eventhub_namespace" "this" {
  count = local.should_deploy_eventhub_namespace ? 1 : 0

  name                          = "${var.resource_prefix}evhns-cslog${local.env}-${var.location}${var.resource_suffix}"
  location                      = data.azurerm_resource_group.this.location
  resource_group_name           = data.azurerm_resource_group.this.name
  sku                           = "Standard"
  capacity                      = 2
  auto_inflate_enabled          = true
  local_authentication_enabled  = true
  maximum_throughput_units      = 10
  minimum_tls_version           = "1.2"
  public_network_access_enabled = true
  network_rulesets {
    default_action                = "Deny"
    public_network_access_enabled = true
    ip_rule = [for ip in var.falcon_ip_addresses : {
      ip_mask = ip
      action  = "Allow"
    }]
  }
  tags = var.tags
}

resource "azurerm_eventhub" "activity_log" {
  count             = local.should_deploy_eventhub_for_activity_log ? 1 : 0
  name              = "${var.resource_prefix}evh-cslogact${local.env}-${var.location}${var.resource_suffix}"
  namespace_id      = azurerm_eventhub_namespace.this[0].id
  partition_count   = 16
  message_retention = 1
}

resource "azurerm_eventhub" "entra_id_log" {
  count             = local.should_deploy_eventhub_for_entra_id_log ? 1 : 0
  name              = "${var.resource_prefix}evh-cslogentid${local.env}-${var.location}${var.resource_suffix}"
  namespace_id      = azurerm_eventhub_namespace.this[0].id
  partition_count   = 16
  message_retention = 1
}

resource "azurerm_eventhub_namespace_authorization_rule" "this" {
  count = local.should_deploy_eventhub_namespace ? 1 : 0

  name                = "${var.resource_prefix}rule-cslogevhns${local.env}-${var.location}${var.resource_suffix}"
  namespace_name      = azurerm_eventhub_namespace.this[0].name
  resource_group_name = data.azurerm_resource_group.this.name

  listen = false
  send   = true
  manage = false
}

locals {
  activity_log_eventhub_id = var.activity_log_settings.enabled ? (local.should_deploy_eventhub_for_activity_log ? azurerm_eventhub.activity_log[0].id : var.activity_log_settings.existing_eventhub.eventhub_resource_id) : ""
  entra_id_log_eventhub_id = var.entra_id_log_settings.enabled ? (local.should_deploy_eventhub_for_entra_id_log ? azurerm_eventhub.entra_id_log[0].id : var.entra_id_log_settings.existing_eventhub.eventhub_resource_id) : ""
}

# Azure Event Hubs Data Receiver role assignments in the infrastructure subscription if realtime visibility feature is enable
resource "azurerm_role_assignment" "activity_log_event_hub_data_receiver" {
  count                            = var.activity_log_settings.enabled ? 1 : 0
  scope                            = local.activity_log_eventhub_id
  role_definition_name             = "Azure Event Hubs Data Receiver"
  principal_id                     = var.app_service_principal_id
  skip_service_principal_aad_check = false
}

resource "azurerm_role_assignment" "entra_id_eventhub_data_receiver" {
  count                            = var.entra_id_log_settings.enabled && (var.entra_id_log_settings.existing_eventhub.use && var.entra_id_log_settings.existing_eventhub.eventhub_resource_id != var.activity_log_settings.existing_eventhub.eventhub_resource_id) ? 1 : 0
  scope                            = local.entra_id_log_eventhub_id
  role_definition_name             = "Azure Event Hubs Data Receiver"
  principal_id                     = var.app_service_principal_id
  skip_service_principal_aad_check = false
}
