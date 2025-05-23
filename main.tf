data "azurerm_client_config" "current" {}

locals {
  subscriptions               = toset(concat(var.cs_infra_subscription_id == "" ? [] : [var.cs_infra_subscription_id], var.subscription_ids))
  management_groups           = toset(length(var.subscription_ids) == 0 && length(var.management_group_ids) == 0 ? [data.azurerm_client_config.current.tenant_id] : var.management_group_ids)
  env                         = var.env == "" ? "" : "-${var.env}"
  should_deploy_log_ingestion = var.enable_realtime_visibility
}

resource "crowdstrike_cloud_azure_tenant" "this" {
  tenant_id                      = data.azurerm_client_config.current.tenant_id
  microsoft_graph_permission_ids = var.microsoft_graph_permission_ids
  realtime_visibility = {
    enabled = var.enable_realtime_visibility
  }
  resource_name_prefix = var.resource_suffix
  resource_name_suffix = var.resource_suffix
  environment          = var.env
  management_group_ids = var.management_group_ids
  subscription_ids     = var.subscription_ids
  tags                 = var.tags
}

module "service_principal" {
  source = "./modules/service-principal/"

  azure_client_id                = crowdstrike_cloud_azure_tenant.this.cs_azure_client_id
  microsoft_graph_permission_ids = var.microsoft_graph_permission_ids != null ? var.microsoft_graph_permission_ids : []
}

module "asset_inventory" {
  source = "./modules/asset-inventory/"

  management_group_ids     = local.management_groups
  subscription_ids         = local.subscriptions
  app_service_principal_id = module.service_principal.object_id
  resource_prefix          = var.resource_prefix
  resource_suffix          = var.resource_suffix

  depends_on = [
    module.service_principal
  ]
}

resource "azurerm_resource_group" "this" {
  count = local.should_deploy_log_ingestion ? 1 : 0

  name     = "${var.resource_prefix}rg-cs${local.env}${var.resource_suffix}"
  location = var.location
  tags     = var.tags
}

module "deployment_scope" {
  source = "./modules/deployment-scope"

  management_group_ids = local.management_groups
  subscription_ids     = local.subscriptions
}

module "log_ingestion" {
  count  = local.should_deploy_log_ingestion ? 1 : 0
  source = "./modules/log-ingestion/"

  subscription_ids         = module.deployment_scope.all_active_subscription_ids
  app_service_principal_id = module.service_principal.object_id
  resource_group_name      = azurerm_resource_group.this[0].name
  activity_log_settings    = var.log_ingestion_settings.activity_log
  entra_id_log_settings    = var.log_ingestion_settings.entra_id_log
  falcon_ip_addresses      = var.falcon_ip_addresses
  env                      = var.env
  location                 = var.location
  resource_prefix          = var.resource_prefix
  resource_suffix          = var.resource_suffix
  tags                     = var.tags

  depends_on = [
    module.deployment_scope,
    azurerm_resource_group.this
  ]
}

resource "crowdstrike_cloud_azure_event_hub_settings" "update_event_hub_settings" {
  count = local.should_deploy_log_ingestion ? 1 : 0

  tenant_id = data.azurerm_client_config.current.tenant_id
  event_hub_settings = concat(
    var.log_ingestion_settings.activity_log.enabled ? [{ purpose = "activity_logs", event_hub_id = module.log_ingestion.activity_log_eventhub_id, consumer_group = module.log_ingestion.activity_log_eventhub_consumer_group_name }] : [],
    var.log_ingestion_settings.entra_id_log.enabled ? [{ purpose = "entra_logs", event_hub_id = module.log_ingestion.entra_id_log_eventhub_id, consumer_group = module.log_ingestion.entra_id_log_eventhub_consumer_group_name }] : [],
  )
}
