data "azurerm_eventhub_namespace" "this" {
  name                = var.eventhub_namespace_name
  resource_group_name = var.resource_group_name
}


data "azurerm_eventhub" "this" {
  name                = var.eventhub_name
  namespace_name      = data.azurerm_eventhub_namespace.this.name
  resource_group_name = var.resource_group_name
}