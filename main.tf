data "azurerm_client_config" "current" {}

locals {
  subscriptions                    = toset(concat(var.cs_infra_subscription_id == "" ? [] : [var.cs_infra_subscription_id], var.subscription_ids))
  management_groups                = toset(length(var.subscription_ids) == 0 && length(var.management_group_ids) == 0 ? [data.azurerm_client_config.current.tenant_id] : var.management_group_ids)
  should_deploy_log_ingestion      = var.enable_realtime_visibility
  should_deploy_agentless_scanning = var.enable_dspm

  microsoft_graph_permission_ids = var.microsoft_graph_permission_ids != null ? var.microsoft_graph_permission_ids : [
    "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30", # Application.Read.All (Role)
    "98830695-27a2-44f7-8c18-0c3ebc9698f6", # GroupMember.Read.All (Role)
    "246dd0d5-5bd0-4def-940b-0421030a5b68", # Policy.Read.All (Role)
    "230c1aed-a721-4c5d-9cb4-a90514e508ef", # Reports.Read.All (Role)
    "483bed4a-2ad3-4361-a73b-c83ccdbdc53c", # RoleManagement.Read.Directory (Role)
    "df021288-bdef-4463-88db-98f22de89214"  # User.Read.All (Role)
  ]
}

resource "crowdstrike_cloud_azure_tenant" "this" {
  tenant_id                      = data.azurerm_client_config.current.tenant_id
  microsoft_graph_permission_ids = local.microsoft_graph_permission_ids
  realtime_visibility = {
    enabled = var.enable_realtime_visibility
  }
  dspm = {
    enabled = var.enable_dspm
  }
  cs_infra_subscription_id = var.cs_infra_subscription_id
  cs_infra_location        = var.location
  resource_name_prefix     = var.resource_prefix
  resource_name_suffix     = var.resource_suffix
  environment              = var.env
  management_group_ids     = var.management_group_ids
  subscription_ids         = var.subscription_ids
  tags                     = var.tags
}

module "service_principal" {
  source = "./modules/service-principal/"

  azure_client_id                = crowdstrike_cloud_azure_tenant.this.cs_azure_client_id
  microsoft_graph_permission_ids = local.microsoft_graph_permission_ids
}

module "asset_inventory" {
  source = "./modules/asset-inventory/"

  tenant_id                = data.azurerm_client_config.current.tenant_id
  management_group_ids     = local.management_groups
  subscription_ids         = local.subscriptions
  app_service_principal_id = module.service_principal.object_id
  resource_prefix          = var.resource_prefix
  resource_suffix          = var.resource_suffix
}

module "crowdstrike_resource_group" {
  count  = local.should_deploy_log_ingestion || local.should_deploy_agentless_scanning ? 1 : 0
  source = "./modules/resource-group"

  location        = var.location
  resource_prefix = var.resource_prefix
  resource_suffix = var.resource_suffix
  env             = var.env
  tags            = var.tags
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
  cs_infra_subscription_id = var.cs_infra_subscription_id
  resource_group_name      = module.crowdstrike_resource_group[0].resource_group_name
  activity_log_settings    = var.log_ingestion_settings.activity_log
  entra_id_log_settings    = var.log_ingestion_settings.entra_id_log
  falcon_ip_addresses      = var.falcon_ip_addresses
  env                      = var.env
  location                 = var.location
  resource_prefix          = var.resource_prefix
  resource_suffix          = var.resource_suffix
  tags                     = var.tags

  depends_on = [module.crowdstrike_resource_group]
}

module "agentless_scanning" {
  count  = local.should_deploy_agentless_scanning ? 1 : 0
  source = "./modules/agentless-scanning"

  deploy_resource_group                               = false
  agentless_scanning_locations                        = var.agentless_scanning_locations
  agentless_scanning_principal_id                     = module.service_principal.object_id
  agentless_scanning_deploy_nat_gateway               = var.agentless_scanning_deploy_nat_gateway
  key_vault_allowed_ip_rules                          = var.key_vault_allowed_ip_rules
  input_enable_dspm                                   = var.enable_dspm
  input_agentless_scanning_locations_per_subscription = var.agentless_scanning_locations_per_subscription
  falcon_client_id                                    = var.falcon_client_id
  falcon_client_secret                                = var.falcon_client_secret
  resource_group_name                                 = module.crowdstrike_resource_group[0].resource_group_name
  resource_prefix                                     = var.resource_prefix
  resource_suffix                                     = var.resource_suffix
  env                                                 = var.env
  tags                                                = var.tags

  depends_on = [module.crowdstrike_resource_group]
}

resource "crowdstrike_cloud_azure_tenant_eventhub_settings" "update_event_hub_settings" {
  tenant_id = data.azurerm_client_config.current.tenant_id

  settings = concat(
    local.should_deploy_log_ingestion && var.log_ingestion_settings.activity_log.enabled ? [
      {
        type           = "activity_logs",
        id             = module.log_ingestion[0].activity_log_eventhub_id,
        consumer_group = module.log_ingestion[0].activity_log_eventhub_consumer_group_name
    }] : [],
    local.should_deploy_log_ingestion && var.log_ingestion_settings.entra_id_log.enabled ? [
      {
        type           = "entra_logs",
        id             = module.log_ingestion[0].entra_id_log_eventhub_id,
        consumer_group = module.log_ingestion[0].entra_id_log_eventhub_consumer_group_name
    }] : []
  )

  depends_on = [
    crowdstrike_cloud_azure_tenant.this,
    module.asset_inventory,
    module.log_ingestion
  ]
}
