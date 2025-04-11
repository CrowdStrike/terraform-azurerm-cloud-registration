# Create service principal
resource "azuread_service_principal" "sp" {
  client_id                    = var.azure_client_id
  app_role_assignment_required = false
}

# Get Microsoft Graph Service Principal
data "azuread_service_principal" "msgraph" {
  display_name = "Microsoft Graph"
}

# Assign application roles
resource "azuread_app_role_assignment" "entra_id_permissions" {
  for_each            = toset(var.entra_id_permissions)
  principal_object_id = azuread_service_principal.sp.object_id
  resource_object_id  = data.azuread_service_principal.msgraph.object_id
  app_role_id         = each.value
}
