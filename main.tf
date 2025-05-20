data "azurerm_client_config" "current" {}

locals {
  subscriptions     = toset(concat(var.cs_infra_subscription_id == "" ? [] : [var.cs_infra_subscription_id], var.subscription_ids))
  management_groups = toset(length(var.subscription_ids) == 0 && length(var.management_group_ids) == 0 ? [data.azurerm_client_config.current.tenant_id] : var.management_group_ids)
  env               = var.env == "" ? "" : "-${var.env}"
}

module "service_principal" {
  source = "./modules/service-principal/"

  azure_client_id                = var.azure_client_id
  microsoft_graph_permission_ids = var.microsoft_graph_permission_ids != null ? var.microsoft_graph_permission_ids : []
}

module "asset_inventory" {
  source = "./modules/asset-inventory/"

  management_group_ids     = local.management_groups
  subscription_ids         = local.subscriptions
  app_service_principal_id = module.service_principal.object_id

  depends_on = [
    module.service_principal
  ]
}

resource "azurerm_resource_group" "this" {
  count = var.log_ingestion_settings.enabled ? 1 : 0

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
  count  = var.log_ingestion_settings.enabled ? 1 : 0
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
