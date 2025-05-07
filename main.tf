data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

locals {
  tenant_id         = var.tenant_id != "" ? var.tenant_id : data.azurerm_client_config.current.tenant_id
  subscriptions     = toset(var.subscription_ids)
  management_groups = toset(var.management_group_ids)
  default_entra_id_permissions = [
    "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30", // Application.Read.All
    "5b567255-7703-4780-807c-7be8301ae99b", // Group.Read.All
    "246dd0d5-5bd0-4def-940b-0421030a5b68", // Policy.Read.All
    "230c1aed-a721-4c5d-9cb4-a90514e508ef", // Reports.Read.All
    "483bed4a-2ad3-4361-a73b-c83ccdbdc53c", // RoleManagement.Read.All
    "df021288-bdef-4463-88db-98f22de89214"  // User.Read.All
  ]
}

module "service_principal" {
  source = "./modules/service-principal/"

  azure_client_id      = var.azure_client_id
  entra_id_permissions = var.custom_entra_id_permissions != null ? var.custom_entra_id_permissions : local.default_entra_id_permissions
  env                  = var.env
  region               = var.region
  resource_prefix      = var.resource_prefix
  resource_suffix      = var.resource_suffix
  tags                 = var.tags
}

module "asset_inventory" {
  source = "./modules/asset-inventory/"

  tenant_id                = local.tenant_id
  management_group_ids     = local.management_groups
  subscription_ids         = local.subscriptions
  cs_infra_subscription_id = var.cs_infra_subscription_id
  app_service_principal_id = module.service_principal.object_id
  env                      = var.env
  region                   = var.region
  resource_prefix          = var.resource_prefix
  resource_suffix          = var.resource_suffix
  tags                     = var.tags

  depends_on = [
    module.service_principal
  ]
}

module "log_ingestion" {
  count  = var.enable_realtime_visibility ? 1 : 0
  source = "./modules/log-ingestion/"
  providers = {
    azurerm.existing_activity_log_eventhub = azurerm.existing_activity_log_eventhub
    azurerm.existing_entra_id_log_eventhub = azurerm.existing_entra_id_log_eventhub
  }

  tenant_id                = local.tenant_id
  management_group_ids     = local.management_groups
  subscription_ids         = module.asset_inventory.all_active_subscription_ids
  cs_infra_subscription_id = var.cs_infra_subscription_id
  app_service_principal_id = module.service_principal.object_id
  activity_log_settings    = var.realtime_visibility_activity_log_settings
  entra_id_log_settings    = var.realtime_visibility_entra_id_log_settings
  falcon_cid               = var.falcon_cid
  falcon_client_id         = var.falcon_client_id
  falcon_client_secret     = var.falcon_client_secret
  falcon_ip_addresses      = var.falcon_ip_addresses
  env                      = var.env
  region                   = var.region
  resource_prefix          = var.resource_prefix
  resource_suffix          = var.resource_suffix
  tags                     = var.tags

  depends_on = [
    module.asset_inventory
  ]
}
