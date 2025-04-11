data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}

locals {
  tenant_id     = var.tenant_id != "" ? var.tenant_id : data.azurerm_client_config.current.tenant_id
  subscriptions = toset(var.subscription_ids)
}

module "service_principal" {
  source = "./modules/service-principal/"

  azure_client_id      = var.azure_client_id
  entra_id_permissions = var.custom_entra_id_permissions

  providers = {
    azuread = azuread
    azurerm = azurerm
  }
}

module "asset_inventory" {
  source = "./modules/asset-inventory/"

  tenant_id            = local.tenant_id
  management_group_ids = var.management_group_ids
  subscription_ids     = var.subscription_ids
  object_id            = module.service_principal.object_id

  depends_on = [
    module.service_principal
  ]

  providers = {
    azurerm = azurerm
  }
}
