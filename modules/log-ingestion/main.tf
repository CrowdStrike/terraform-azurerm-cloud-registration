locals {
  activity_log_diagnostic_settings_default_name = "${var.resource_prefix}diag-cslogact${local.env}${var.resource_suffix}"
  entra_id_log_diagnostic_settings_default_name = "${var.resource_prefix}diag-cslogentid${local.env}${var.resource_suffix}"
  subscription_scopes                           = [for id in var.subscription_ids : "/subscriptions/${id}"]
  should_deploy_eventhub_for_activity_log       = var.activity_log_settings.enabled && !var.activity_log_settings.existing_eventhub.use
  should_deploy_eventhub_for_entra_id_log       = var.entra_id_log_settings.enabled && !var.entra_id_log_settings.existing_eventhub.use
  should_deploy_eventhub_namespace              = local.should_deploy_eventhub_for_activity_log || local.should_deploy_eventhub_for_entra_id_log
  env                                           = var.env == "" ? "" : "-${var.env}"
}

data "azurerm_client_config" "this" {}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "random_string" "eventhub_namespace" {
  count = local.should_deploy_eventhub_namespace ? 1 : 0

  length = 13
  keepers = {
    tenant_id           = data.azurerm_client_config.this.tenant_id
    subscription_id     = data.azurerm_client_config.this.subscription_id
    resource_group_name = data.azurerm_resource_group.this.name
    env                 = var.env
    location            = var.location
  }
  special = false
}

resource "azurerm_eventhub_namespace" "this" {
  count = local.should_deploy_eventhub_namespace ? 1 : 0

  name                          = "${var.resource_prefix}evhns-cslog-${random_string.eventhub_namespace[0].id}${var.resource_suffix}"
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
    default_action                 = "Deny"
    public_network_access_enabled  = true
    trusted_service_access_enabled = true
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
  activity_log_eventhub_id                  = var.activity_log_settings.enabled ? (local.should_deploy_eventhub_for_activity_log ? azurerm_eventhub.activity_log[0].id : var.activity_log_settings.existing_eventhub.eventhub_resource_id) : ""
  activity_log_eventhub_consumer_group_name = var.activity_log_settings.enabled ? (local.should_deploy_eventhub_for_activity_log ? "$Default" : var.activity_log_settings.existing_eventhub.eventhub_consumer_group_name) : ""
  entra_id_log_eventhub_id                  = var.entra_id_log_settings.enabled ? (local.should_deploy_eventhub_for_entra_id_log ? azurerm_eventhub.entra_id_log[0].id : var.entra_id_log_settings.existing_eventhub.eventhub_resource_id) : ""
  entra_id_log_eventhub_consumer_group_name = var.entra_id_log_settings.enabled ? (local.should_deploy_eventhub_for_entra_id_log ? "$Default" : var.entra_id_log_settings.existing_eventhub.eventhub_consumer_group_name) : ""
  parsed_existing_activity_log_eventhub_id  = var.activity_log_settings.enabled && !local.should_deploy_eventhub_for_activity_log ? provider::azurerm::parse_resource_id(var.activity_log_settings.existing_eventhub.eventhub_resource_id) : provider::azurerm::parse_resource_id("/subscriptions/12345678-1234-5678-9abc-123456789012/resourceGroups/fake-rg/providers/Microsoft.EventHub/namespaces/fake-evhns/eventhubs/fake-evh")
  parsed_existing_entra_id_log_eventhub_id  = var.entra_id_log_settings.enabled && !local.should_deploy_eventhub_for_entra_id_log ? provider::azurerm::parse_resource_id(var.entra_id_log_settings.existing_eventhub.eventhub_resource_id) : provider::azurerm::parse_resource_id("/subscriptions/12345678-1234-5678-9abc-123456789012/resourceGroups/fake-rg/providers/Microsoft.EventHub/namespaces/fake-evhns/eventhubs/fake-evh")
  activity_log_eventhub_resource_group_id  = var.activity_log_settings.enabled ? (local.should_deploy_eventhub_for_activity_log ? "/subscriptions/${var.cs_infra_subscription_id}/resourceGroups/${var.resource_group_name}" : "/subscriptions/${local.parsed_existing_activity_log_eventhub_id.subscription_id}/resourceGroups/${local.parsed_existing_activity_log_eventhub_id.resource_group_name}") : ""
  entra_id_log_eventhub_resource_grouop_id  = var.entra_id_log_settings.enabled ? (local.should_deploy_eventhub_for_entra_id_log ? "/subscriptions/${var.cs_infra_subscription_id}/resourceGroups/${var.resource_group_name}" : "/subscriptions/${local.parsed_existing_entra_id_log_eventhub_id.subscription_id}/resourceGroups/${local.parsed_existing_entra_id_log_eventhub_id.resource_group_name}") : ""
}

# Azure Event Hubs Data Receiver role assignments in the infrastructure subscription if realtime visibility feature is enable
resource "azurerm_role_assignment" "activity_log_event_hub_data_receiver" {
  count                            = var.activity_log_settings.enabled ? 1 : 0
  scope                            = local.activity_log_eventhub_resource_grouop_id
  role_definition_name             = "Azure Event Hubs Data Receiver"
  principal_id                     = var.app_service_principal_id
  skip_service_principal_aad_check = false

  depends_on = [data.azurerm_resource_group.this]
}

resource "azurerm_role_assignment" "entra_id_eventhub_data_receiver" {
  count                            = var.entra_id_log_settings.enabled && local.activity_log_eventhub_resource_grouop_id != local.entra_id_log_eventhub_resource_grouop_id ? 1 : 0
  scope                            = local.entra_id_log_eventhub_resource_grouop_id
  role_definition_name             = "Azure Event Hubs Data Receiver"
  principal_id                     = var.app_service_principal_id
  skip_service_principal_aad_check = false

  depends_on = [data.azurerm_resource_group.this]
}
