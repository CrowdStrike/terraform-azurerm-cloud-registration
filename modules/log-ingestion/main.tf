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
  shouldDeployRemediationPolicy            = var.activity_log_settings.enabled && var.deploy_remediation_policy
}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}


module "new_eventhub" {
  source = "./modules/eventhub"
  count  = local.shouldDeployEventHubNamespace ? 1 : 0

  resource_group_name   = data.azurerm_resource_group.this.name
  activity_log_settings = var.activity_log_settings
  entra_id_log_settings = var.entra_id_log_settings
  falcon_ip_addresses   = var.falcon_ip_addresses
  resource_prefix       = var.resource_prefix
  resource_suffix       = var.resource_suffix
  env                   = var.env
  region                = var.region
  tags                  = var.tags

  depends_on = [
    data.azurerm_resource_group.this
  ]
}

module "existing_activity_log_eventhub" {
  count  = !local.shouldDeployEventHubForActivityLog && var.activity_log_settings.enabled ? 1 : 0
  source = "./modules/existing-eventhub"
  providers = {
    azurerm = azurerm.existing_activity_log_eventhub
  }

  subscription_id         = var.activity_log_settings.existing_eventhub.subscription_id
  resource_group_name     = var.activity_log_settings.existing_eventhub.resource_group_name
  eventhub_name           = var.activity_log_settings.existing_eventhub.name
  eventhub_namespace_name = var.activity_log_settings.existing_eventhub.namespace_name
}

module "existing_entra_id_log_eventhub" {
  count  = !local.shouldDeployEventHubForEntraIDLog && var.entra_id_log_settings.enabled ? 1 : 0
  source = "./modules/existing-eventhub"
  providers = {
    azurerm = azurerm.existing_entra_id_log_eventhub
  }

  subscription_id         = var.entra_id_log_settings.existing_eventhub.subscription_id
  resource_group_name     = var.entra_id_log_settings.existing_eventhub.resource_group_name
  eventhub_name           = var.entra_id_log_settings.existing_eventhub.name
  eventhub_namespace_name = var.entra_id_log_settings.existing_eventhub.namespace_name
}

locals {
  activityLogEventHubNamespaceName       = var.activity_log_settings.enabled ? (local.shouldDeployEventHubForActivityLog ? module.new_eventhub[0].eventhub_namespace_name : module.existing_activity_log_eventhub[0].eventhub_namespace_name) : ""
  activityLogEventHubNamespaceId         = var.activity_log_settings.enabled ? (local.shouldDeployEventHubForActivityLog ? module.new_eventhub[0].eventhub_namespace_id : module.existing_activity_log_eventhub[0].eventhub_namespace_id) : ""
  activityLogEventHubName                = var.activity_log_settings.enabled ? (local.shouldDeployEventHubForActivityLog ? module.new_eventhub[0].activity_log_eventhub_name : module.existing_activity_log_eventhub[0].eventhub_name) : ""
  activityLogEventHubId                  = var.activity_log_settings.enabled ? (local.shouldDeployEventHubForActivityLog ? module.new_eventhub[0].activity_log_eventhub_id : module.existing_activity_log_eventhub[0].eventhub_id) : ""
  activityLogEventHubConsumerGroupName   = var.activity_log_settings.enabled ? (local.shouldDeployEventHubForActivityLog ? "$Default" : var.activity_log_settings.existing_eventhub.consumer_group_name) : ""
  activityLogEventHubAuthorizationRuleId = var.activity_log_settings.enabled ? (local.shouldDeployEventHubForActivityLog ? module.new_eventhub[0].eventhub_namespace_authorization_rule_id : var.activity_log_settings.existing_eventhub.authorization_rule_id) : ""
  activityLogEventHubSubscriptionId      = var.activity_log_settings.enabled ? (local.shouldDeployEventHubForActivityLog ? var.cs_infra_subscription_id : var.activity_log_settings.existing_eventhub.subscription_id) : ""
  entraIDLogEventHubNamespaceName        = var.entra_id_log_settings.enabled ? (local.shouldDeployEventHubForEntraIDLog ? module.new_eventhub[0].eventhub_namespace_name : module.existing_entra_id_log_eventhub[0].eventhub_namespace_name) : ""
  entraIDLogEventHubNamespaceId          = var.entra_id_log_settings.enabled ? (local.shouldDeployEventHubForEntraIDLog ? module.new_eventhub[0].eventhub_namespace_id : module.existing_entra_id_log_eventhub[0].eventhub_namespace_id) : ""
  entraIDLogEventHubName                 = var.entra_id_log_settings.enabled ? (local.shouldDeployEventHubForEntraIDLog ? module.new_eventhub[0].entra_id_log_eventhub_name : module.existing_entra_id_log_eventhub[0].eventhub_name) : ""
  entraIDLogEventHubId                   = var.entra_id_log_settings.enabled ? (local.shouldDeployEventHubForEntraIDLog ? module.new_eventhub[0].entra_id_log_eventhub_id : module.existing_entra_id_log_eventhub[0].eventhub_id) : ""
  entraIDLogEventHubConsumerGroupName    = var.entra_id_log_settings.enabled ? (local.shouldDeployEventHubForEntraIDLog ? "$Default" : var.entra_id_log_settings.existing_eventhub.consumer_group_name) : ""
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