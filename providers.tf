provider "azurerm" {
  subscription_id = var.cs_infrastructure_subscription_id
  features {}
}

provider "azuread" {}

provider "azurerm" {
  alias           = "infra"
  subscription_id = var.cs_infrastructure_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "existing_activity_log_eventhub"
  subscription_id = var.feature_settings.realtime_visibility_detection.activity_log.enabled && var.feature_settings.realtime_visibility_detection.activity_log.use_existing_event_hub && var.feature_settings.realtime_visibility_detection.activity_log.event_hub_subscription_id != "" ? var.feature_settings.realtime_visibility_detection.activity_log.event_hub_subscription_id : var.cs_infrastructure_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "existing_entra_id_log_eventhub"
  subscription_id = var.feature_settings.realtime_visibility_detection.entra_id_log.enabled && var.feature_settings.realtime_visibility_detection.entra_id_log.use_existing_event_hub && var.feature_settings.realtime_visibility_detection.entra_id_log.event_hub_subscription_id != "" ? var.feature_settings.realtime_visibility_detection.entra_id_log.event_hub_subscription_id : var.cs_infrastructure_subscription_id
  features {}
}