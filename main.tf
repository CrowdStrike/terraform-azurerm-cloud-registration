data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

locals {
  tenant_id                = var.tenant_id != "" ? var.tenant_id : data.azurerm_client_config.current.tenant_id
  subscriptions            = toset(var.subscription_ids)
  management_groups        = toset(var.management_group_ids)
  app_service_principal_id = "ee99a605-d48c-4806-a769-d76f88e96570"
}

# module "service_principal" {
#   source = "./modules/service-principal/"
#
#   azure_client_id      = var.azure_client_id
#   entra_id_permissions = var.custom_entra_id_permissions
#   env                  = var.env
#   region               = var.region
#   resource_name_prefix = var.resource_name_prefix
#   resource_name_suffix = var.resource_name_suffix
#   tags                 = var.tags
# }

module "asset_inventory" {
  source = "./modules/asset-inventory/"

  tenant_id                         = local.tenant_id
  management_group_ids              = local.management_groups
  subscription_ids                  = local.subscriptions
  cs_infrastructure_subscription_id = var.cs_infrastructure_subscription_id
  feature_settings                  = var.feature_settings
  #app_service_principal_id                         = module.service_principal.object_id
  app_service_principal_id = local.app_service_principal_id
  env                      = var.env
  region                   = var.region
  resource_name_prefix     = var.resource_name_prefix
  resource_name_suffix     = var.resource_name_suffix
  tags                     = var.tags

  # depends_on = [
  #   module.service_principal
  # ]
}

module "log_ingestion" {
  source = "./modules/log-ingestion/"
  providers = {
    azurerm                                = azurerm.infra
    azurerm.existing_activity_log_eventhub = azurerm.existing_activity_log_eventhub
    azurerm.existing_entra_id_log_eventhub = azurerm.existing_entra_id_log_eventhub
  }

  tenant_id            = local.tenant_id
  management_group_ids = local.management_groups
  #subscription_ids                  = module.asset_inventory.all_active_subscription_ids
  subscription_ids                  = local.subscriptions
  cs_infrastructure_subscription_id = var.cs_infrastructure_subscription_id
  #app_service_principal_id                         = module.service_principal.object_id
  app_service_principal_id = local.app_service_principal_id
  feature_settings         = var.feature_settings
  falcon_cid               = var.falcon_cid
  falcon_client_id         = var.falcon_client_id
  falcon_client_secret     = var.falcon_client_secret
  falcon_ip_addresses      = var.falcon_ip_addresses
  env                      = var.env
  region                   = var.region
  resource_name_prefix     = var.resource_name_prefix
  resource_name_suffix     = var.resource_name_suffix
  tags                     = var.tags

  depends_on = [
    module.asset_inventory
  ]
}
