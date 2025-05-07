locals {
  shouldDeployEventHubForActivityLog = var.feature_settings.realtime_visibility_detection.activity_log.enabled && !var.feature_settings.realtime_visibility_detection.activity_log.use_existing_event_hub
  shouldDeployEventHubForEntraIDLog  = var.feature_settings.realtime_visibility_detection.entra_id_log.enabled && !var.feature_settings.realtime_visibility_detection.entra_id_log.use_existing_event_hub
}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azurerm_eventhub_namespace" "this" {
  name                          = "${var.prefix}evhns-cslog-${var.env}-${var.region}${var.suffix}"
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

resource "azurerm_eventhub" "activity-log" {
  count             = local.shouldDeployEventHubForActivityLog ? 1 : 0
  name              = "${var.prefix}evh-cslogact-${var.env}-${var.region}${var.suffix}"
  namespace_id      = azurerm_eventhub_namespace.this.id
  partition_count   = 16
  message_retention = 1
}

resource "azurerm_eventhub" "entra-id-log" {
  count             = local.shouldDeployEventHubForEntraIDLog ? 1 : 0
  name              = "${var.prefix}evh-cslogentid-${var.env}-${var.region}${var.suffix}"
  namespace_id      = azurerm_eventhub_namespace.this.id
  partition_count   = 16
  message_retention = 1
}

resource "azurerm_eventhub_namespace_authorization_rule" "this" {
  name                = "${var.prefix}rule-cslogevhns-${var.env}-${var.region}${var.suffix}"
  namespace_name      = azurerm_eventhub_namespace.this.name
  resource_group_name = data.azurerm_resource_group.this.name

  listen = false
  send   = true
  manage = false
}