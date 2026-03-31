locals {
  environment = var.env == "" ? "" : "-${var.env}"
}

resource "azurerm_resource_group" "this" {
  name     = "${var.resource_prefix}rg-cs${local.environment}${var.resource_suffix}"
  location = var.location

  tags = merge(var.tags, {
    CSTagResourceType = "ResourceGroup"
  })
}
