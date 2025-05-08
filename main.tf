data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

locals {
  tenant_id         = var.tenant_id != "" ? var.tenant_id : data.azurerm_client_config.current.tenant_id
  subscriptions     = toset(var.subscription_ids)
  management_groups = toset(var.management_group_ids)
  env               = var.env == "" ? "" : "-${var.env}"
  falcon_ip_addresses = {
    US-1 : [
      "13.52.148.107",
      "52.52.20.134",
      "54.176.76.126",
      "54.176.197.246"
    ],
    US-2 : [
      "35.160.117.193",
      "52.43.192.139",
      "54.187.226.134",
      "44.238.201.139",
      "35.155.6.7",
      "54.185.138.46"
    ],
    EU-1 : [
      "3.73.169.253",
      "18.158.141.230",
      "18.195.129.87",
      "3.64.87.158",
      "18.184.139.200"
    ]
  }
}

module "service_principal" {
  source = "./modules/service-principal/"

  azure_client_id      = var.azure_client_id
  entra_id_permissions = var.custom_entra_id_permissions != null ? var.custom_entra_id_permissions : []
}

module "asset_inventory" {
  source = "./modules/asset-inventory/"

  tenant_id                = local.tenant_id
  management_group_ids     = local.management_groups
  subscription_ids         = local.subscriptions
  app_service_principal_id = module.service_principal.object_id

  depends_on = [
    module.service_principal
  ]
}

resource "azurerm_resource_group" "this" {
  count = var.enable_realtime_visibility ? 1 : 0

  name     = "${var.resource_prefix}rg-cs${local.env}${var.resource_suffix}"
  location = var.region
  tags     = var.tags
}

module "deployment_scope" {
  source = "./modules/deployment-scope"

  management_group_ids = local.management_groups
  subscription_ids     = local.subscriptions
}

module "log_ingestion" {
  count  = var.enable_realtime_visibility ? 1 : 0
  source = "./modules/log-ingestion/"
  providers = {
    azurerm.existing_activity_log_eventhub = azurerm.existing_activity_log_eventhub
    azurerm.existing_entra_id_log_eventhub = azurerm.existing_entra_id_log_eventhub
  }

  tenant_id                 = local.tenant_id
  management_group_ids      = local.management_groups
  subscription_ids          = module.deployment_scope.all_active_subscription_ids
  cs_infra_subscription_id  = var.cs_infra_subscription_id
  app_service_principal_id  = module.service_principal.object_id
  resource_group_name       = azurerm_resource_group.this[0].name
  deploy_remediation_policy = var.deploy_realtime_visibility_remediation_policy
  activity_log_settings     = var.realtime_visibility_activity_log_settings
  entra_id_log_settings     = var.realtime_visibility_entra_id_log_settings
  falcon_ip_addresses       = local.falcon_ip_addresses[var.falcon_cloud_region]
  env                       = var.env
  region                    = var.region
  resource_prefix           = var.resource_prefix
  resource_suffix           = var.resource_suffix
  tags                      = var.tags

  depends_on = [
    module.deployment_scope,
    azurerm_resource_group.this
  ]
}
