provider "azurerm" {
  subscription_id = var.cs_infra_subscription_id
  features {}
}

provider "azuread" {}

provider "azurerm" {
  alias           = "existing_activity_log_eventhub"
  subscription_id = var.realtime_visibility_activity_log_settings.enabled && var.realtime_visibility_activity_log_settings.existing_eventhub.use && var.realtime_visibility_activity_log_settings.existing_eventhub.subscription_id != "" ? var.realtime_visibility_activity_log_settings.existing_eventhub.subscription_id : var.cs_infra_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "existing_entra_id_log_eventhub"
  subscription_id = var.realtime_visibility_entra_id_log_settings.enabled && var.realtime_visibility_entra_id_log_settings.existing_eventhub.use && var.realtime_visibility_entra_id_log_settings.existing_eventhub.subscription_id != "" ? var.realtime_visibility_entra_id_log_settings.existing_eventhub.subscription_id : var.cs_infra_subscription_id
  features {}
}