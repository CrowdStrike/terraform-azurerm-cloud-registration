data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

locals {
  tenant_id                                = var.tenant_id != "" ? var.tenant_id : data.azurerm_client_config.current.tenant_id
  prefix                                   = var.resource_name_prefix != "" ? "${var.resource_name_prefix}-" : ""
  suffix                                   = var.resource_name_suffix != "" ? "-${var.resource_name_suffix}" : ""
  activityLogDiagnosticSettingsDefaultName = "${local.prefix}diag-csliactivity${local.suffix}"
  entraIDLogDiagnosticSettingsDefaultName  = "${local.prefix}diag-cslientid${local.suffix}"
  subscription_scopes                      = [for id in var.subscription_ids : "/subscriptions/${id}"]
  management_group_scopes                  = [for id in var.management_group_ids : "/providers/Microsoft.Management/managementGroups/${id}"]
  activityLogEnabled                       = var.feature_settings.realtime_visibility_detection.enabled && var.feature_settings.realtime_visibility_detection.activity_log.enabled
  entraIDLogEnabled                        = var.feature_settings.realtime_visibility_detection.enabled && var.feature_settings.realtime_visibility_detection.entra_id_log.enabled
  shouldDeployEventHubForActivityLog       = local.activityLogEnabled && !var.feature_settings.realtime_visibility_detection.activity_log.use_existing_event_hub
  shouldDeployEventHubForEntraIDLog        = local.entraIDLogEnabled && !var.feature_settings.realtime_visibility_detection.entra_id_log.use_existing_event_hub
  shouldDeployEventHubNamespace            = local.shouldDeployEventHubForActivityLog || local.shouldDeployEventHubForEntraIDLog
  shouldDeployRemediationPolicy            = local.activityLogEnabled && var.feature_settings.realtime_visibility_detection.activity_log.deploy_remediation_policy
  activityLogEventHubNamespaceName         = local.activityLogEnabled ? (local.shouldDeployEventHubForActivityLog ? module.new_eventhub[0].eventhub_namespace_name : module.existing_activity_log_eventhub[0].eventhub_namespace_name) : ""
  activityLogEventHubNamespaceId           = local.activityLogEnabled ? (local.shouldDeployEventHubForActivityLog ? module.new_eventhub[0].eventhub_namespace_id : module.existing_activity_log_eventhub[0].eventhub_namespace_id) : ""
  activityLogEventHubName                  = local.activityLogEnabled ? (local.shouldDeployEventHubForActivityLog ? module.new_eventhub[0].activity_log_eventhub_name : module.existing_activity_log_eventhub[0].eventhub_name) : ""
  activityLogEventHubId                    = local.activityLogEnabled ? (local.shouldDeployEventHubForActivityLog ? module.new_eventhub[0].activity_log_eventhub_id : module.existing_activity_log_eventhub[0].eventhub_id) : ""
  activityLogEventHubConsumerGroupName     = local.activityLogEnabled ? (local.shouldDeployEventHubForActivityLog ? "$Default" : var.feature_settings.realtime_visibility_detection.activity_log.event_hub_consumer_group_name) : ""
  activityLogEventHubAuthorizationRuleId   = local.activityLogEnabled ? (local.shouldDeployEventHubForActivityLog ? module.new_eventhub[0].eventhub_namespace_authorization_rule_id : "") : ""
  activityLogEventHubSubscriptionId        = local.activityLogEnabled ? (local.shouldDeployEventHubForActivityLog ? var.cs_infrastructure_subscription_id : var.feature_settings.realtime_visibility_detection.activity_log.event_hub_subscription_id) : ""
  entraIDLogEventHubNamespaceName          = local.entraIDLogEnabled ? (local.shouldDeployEventHubForEntraIDLog ? module.new_eventhub[0].eventhub_namespace_name : module.existing_entra_id_log_eventhub[0].eventhub_namespace_name) : ""
  entraIDLogEventHubNamespaceId            = local.entraIDLogEnabled ? (local.shouldDeployEventHubForEntraIDLog ? module.new_eventhub[0].eventhub_namespace_id : module.existing_entra_id_log_eventhub[0].eventhub_namespace_id) : ""
  entraIDLogEventHubName                   = local.entraIDLogEnabled ? (local.shouldDeployEventHubForEntraIDLog ? module.new_eventhub[0].entra_id_log_eventhub_name : module.existing_entra_id_log_eventhub[0].eventhub_name) : ""
  entraIDLogEventHubId                     = local.entraIDLogEnabled ? (local.shouldDeployEventHubForEntraIDLog ? module.new_eventhub[0].entra_id_log_eventhub_id : module.existing_entra_id_log_eventhub[0].eventhub_id) : ""
  entraIDLogEventHubConsumerGroupName      = local.entraIDLogEnabled ? (local.shouldDeployEventHubForEntraIDLog ? "$Default" : var.feature_settings.realtime_visibility_detection.entra_id_log.event_hub_consumer_group_name) : ""
}

resource "azurerm_resource_group" "this" {
  name     = "${local.prefix}rg-csli-${var.env}${local.suffix}"
  location = var.region
  tags     = var.tags
}


module "new_eventhub" {
  source = "./modules/eventhub"
  count  = local.shouldDeployEventHubNamespace ? 1 : 0

  resource_group_name = azurerm_resource_group.this.name
  feature_settings    = var.feature_settings
  falcon_ip_addresses = var.falcon_ip_addresses
  prefix              = local.prefix
  suffix              = local.suffix
  env                 = var.env
  region              = var.region
  tags                = var.tags
}

module "existing_activity_log_eventhub" {
  count  = !local.shouldDeployEventHubForActivityLog && var.feature_settings.realtime_visibility_detection.activity_log.enabled ? 1 : 0
  source = "./modules/existing-eventhub"
  providers = {
    azurerm = azurerm.existing_activity_log_eventhub
  }

  subscription_id         = var.feature_settings.realtime_visibility_detection.activity_log.event_hub_subscription_id
  resource_group_name     = var.feature_settings.realtime_visibility_detection.activity_log.event_hub_resource_group_name
  eventhub_name           = var.feature_settings.realtime_visibility_detection.activity_log.event_hub_name
  eventhub_namespace_name = var.feature_settings.realtime_visibility_detection.activity_log.event_hub_namespace_name
}

module "existing_entra_id_log_eventhub" {
  count  = !local.shouldDeployEventHubForEntraIDLog && var.feature_settings.realtime_visibility_detection.entra_id_log.enabled ? 1 : 0
  source = "./modules/existing-eventhub"
  providers = {
    azurerm = azurerm.existing_entra_id_log_eventhub
  }

  subscription_id         = var.feature_settings.realtime_visibility_detection.entra_id_log.event_hub_subscription_id
  resource_group_name     = var.feature_settings.realtime_visibility_detection.entra_id_log.event_hub_resource_group_name
  eventhub_name           = var.feature_settings.realtime_visibility_detection.entra_id_log.event_hub_name
  eventhub_namespace_name = var.feature_settings.realtime_visibility_detection.entra_id_log.event_hub_namespace_name
}

# Azure Event Hubs Data Receiver role assignments in the infrastructure subscription if real time visibility and detection feature is enable
resource "azurerm_role_assignment" "eventhub-data-receiver" {
  count                            = local.activityLogEnabled ? 1 : 0
  scope                            = "/subscriptions/${local.activityLogEventHubSubscriptionId}"
  role_definition_name             = "Azure Event Hubs Data Receiver"
  principal_id                     = var.app_service_principal_id
  skip_service_principal_aad_check = false
}