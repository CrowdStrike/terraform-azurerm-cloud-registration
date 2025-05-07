data "azurerm_management_group" "groups" {
  for_each = toset(var.management_group_ids)
  name     = each.value
}