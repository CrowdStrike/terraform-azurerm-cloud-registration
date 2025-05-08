data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

locals {
  tenant_id                                = var.tenant_id != "" ? var.tenant_id : data.azurerm_client_config.current.tenant_id
  activityLogDiagnosticSettingsDefaultName = "${var.resource_prefix}diag-cslogact${var.resource_suffix}"
  entraIDLogDiagnosticSettingsDefaultName  = "${var.resource_prefix}diag-cslogentid${var.resource_suffix}"
  subscription_scopes                      = [for id in var.subscription_ids : "/subscriptions/${id}"]
  management_group_scopes                  = [for id in var.management_group_ids : "/providers/Microsoft.Management/managementGroups/${id}"]
  shouldDeployEventHubForActivityLog       = var.activity_log_settings.enabled && !var.activity_log_settings.existing_eventhub.use
  shouldDeployEventHubForEntraIDLog        = var.entra_id_log_settings.enabled && !var.entra_id_log_settings.existing_eventhub.use
  shouldDeployEventHubNamespace            = local.shouldDeployEventHubForActivityLog || local.shouldDeployEventHubForEntraIDLog
  shouldDeployRemediationPolicy            = local.shouldDeployEventHubForActivityLog && var.deploy_remediation_policy
}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}


resource "azurerm_eventhub_namespace" "this" {
  count = local.shouldDeployEventHubNamespace ? 1 : 0

  name                          = "${var.resource_prefix}evhns-cslog-${var.env}-${var.region}${var.resource_suffix}"
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
  name              = "${var.resource_prefix}evh-cslogact-${var.env}-${var.region}${var.resource_suffix}"
  namespace_id      = azurerm_eventhub_namespace.this[0].id
  partition_count   = 16
  message_retention = 1
}

resource "azurerm_eventhub" "entra-id-log" {
  count             = local.shouldDeployEventHubForEntraIDLog ? 1 : 0
  name              = "${var.resource_prefix}evh-cslogentid-${var.env}-${var.region}${var.resource_suffix}"
  namespace_id      = azurerm_eventhub_namespace.this[0].id
  partition_count   = 16
  message_retention = 1
}

resource "azurerm_eventhub_namespace_authorization_rule" "this" {
  count = local.shouldDeployEventHubNamespace ? 1 : 0

  name                = "${var.resource_prefix}rule-cslogevhns-${var.env}-${var.region}${var.resource_suffix}"
  namespace_name      = azurerm_eventhub_namespace.this[0].name
  resource_group_name = data.azurerm_resource_group.this.name

  listen = false
  send   = true
  manage = false
}

locals {
  activityLogEventHubNamespaceName       = var.activity_log_settings.enabled ? (local.shouldDeployEventHubForActivityLog ? azurerm_eventhub_namespace.this[0].name : data.azurerm_eventhub_namespace.activity-log[0].name) : ""
  activityLogEventHubNamespaceId         = var.activity_log_settings.enabled ? (local.shouldDeployEventHubForActivityLog ? azurerm_eventhub_namespace.this[0].id : data.azurerm_eventhub_namespace.activity-log[0].id) : ""
  activityLogEventHubName                = var.activity_log_settings.enabled ? (local.shouldDeployEventHubForActivityLog ? azurerm_eventhub.activity-log[0].name : data.azurerm_eventhub.activity-log[0].name) : ""
  activityLogEventHubId                  = var.activity_log_settings.enabled ? (local.shouldDeployEventHubForActivityLog ? azurerm_eventhub.activity-log[0].id : data.azurerm_eventhub.activity-log[0].id) : ""
  activityLogEventHubConsumerGroupName   = var.activity_log_settings.enabled ? (local.shouldDeployEventHubForActivityLog ? "$Default" : var.activity_log_settings.existing_eventhub.consumer_group_name) : ""
  activityLogEventHubAuthorizationRuleId = var.activity_log_settings.enabled ? (local.shouldDeployEventHubForActivityLog ? azurerm_eventhub_namespace_authorization_rule.this[0].id : var.activity_log_settings.existing_eventhub.authorization_rule_id) : ""
  activityLogEventHubSubscriptionId      = var.activity_log_settings.enabled ? (local.shouldDeployEventHubForActivityLog ? var.cs_infra_subscription_id : var.activity_log_settings.existing_eventhub.subscription_id) : ""
  entraIDLogEventHubNamespaceName        = var.entra_id_log_settings.enabled ? (local.shouldDeployEventHubForEntraIDLog ? azurerm_eventhub_namespace.this[0].name : data.azurerm_eventhub_namespace.entra-id-log[0].name) : ""
  entraIDLogEventHubNamespaceId          = var.entra_id_log_settings.enabled ? (local.shouldDeployEventHubForEntraIDLog ? azurerm_eventhub_namespace.this[0].id : data.azurerm_eventhub_namespace.entra-id-log[0].id) : ""
  entraIDLogEventHubName                 = var.entra_id_log_settings.enabled ? (local.shouldDeployEventHubForEntraIDLog ? azurerm_eventhub.entra-id-log[0].name : data.azurerm_eventhub.entra-id-log[0].name) : ""
  entraIDLogEventHubId                   = var.entra_id_log_settings.enabled ? (local.shouldDeployEventHubForEntraIDLog ? azurerm_eventhub.entra-id-log[0].id : data.azurerm_eventhub.entra-id-log[0].id) : ""
  entraIDLogEventHubConsumerGroupName    = var.entra_id_log_settings.enabled ? (local.shouldDeployEventHubForEntraIDLog ? "$Default" : var.entra_id_log_settings.existing_eventhub.consumer_group_name) : ""
  entraIDLogEventHubAuthorizationRuleId  = var.activity_log_settings.enabled ? (local.shouldDeployEventHubForActivityLog ? azurerm_eventhub_namespace_authorization_rule.this[0].id : var.entra_id_log_settings.existing_eventhub.authorization_rule_id) : ""
  entraIDLogEventHubSubscriptionId       = var.entra_id_log_settings.enabled ? (local.shouldDeployEventHubForEntraIDLog ? var.cs_infra_subscription_id : var.entra_id_log_settings.existing_eventhub.subscription_id) : ""
}

# Azure Event Hubs Data Receiver role assignments in the infrastructure subscription if realtime visibility feature is enable
resource "azurerm_role_assignment" "activity-log-eventhub-data-receiver" {
  count                            = var.activity_log_settings.enabled ? 1 : 0
  scope                            = "/subscriptions/${local.activityLogEventHubSubscriptionId}"
  role_definition_name             = "Azure Event Hubs Data Receiver"
  principal_id                     = var.app_service_principal_id
  skip_service_principal_aad_check = false
}

resource "azurerm_role_assignment" "entra-id-eventhub-data-receiver" {
  count                            = var.entra_id_log_settings.enabled && local.entraIDLogEventHubSubscriptionId != local.activityLogEventHubSubscriptionId ? 1 : 0
  scope                            = "/subscriptions/${local.entraIDLogEventHubSubscriptionId}"
  role_definition_name             = "Azure Event Hubs Data Receiver"
  principal_id                     = var.app_service_principal_id
  skip_service_principal_aad_check = false
}