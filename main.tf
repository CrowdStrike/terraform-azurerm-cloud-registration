provider "crowdstrike" {
  client_id     = var.cs_client_id
  client_secret = var.cs_client_secret
}

provider "azuread" {
  tenant_id = var.tenant_id
}

provider "azurerm" {
  tenant_id       = var.tenant_id
  subscription_id = var.default_subscription_id != "" ? var.default_subscription_id : element(var.subscription_ids, 0)
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_client_config" "current" {
}

data "crowdstrike_horizon_azure_client_id" "target" {
  tenant_id = var.tenant_id != "" ? var.tenant_id : data.azurerm_client_config.current.tenant_id
}

module "service_principal" {
  source = "./modules/service-principal/"

  azure_client_id            = var.azure_client_id
  use_azure_management_group = var.use_azure_management_group
  default_subscription_id    = coalesce(var.default_subscription_id, data.azurerm_client_config.current.subscription_id)
  is_commercial              = var.is_commercial

  depends_on = [
    data.crowdstrike_horizon_azure_client_id.target
  ]

  providers = {
    azuread     = azuread
    azurerm     = azurerm
    crowdstrike = crowdstrike
  }
}

module "asset_inventory" {
  source = "./modules/asset-inventory/"

  tenant_id                  = module.service_principal.tenant_id
  object_id                  = module.service_principal.object_id
  subscription_ids           = var.subscription_ids
  is_commercial              = var.is_commercial
  use_azure_management_group = var.use_azure_management_group

  depends_on = [
    module.service_principal
  ]

  providers = {
    azurerm     = azurerm
    crowdstrike = crowdstrike
  }
}
