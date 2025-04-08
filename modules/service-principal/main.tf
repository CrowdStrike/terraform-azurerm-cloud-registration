data "azuread_client_config" "client" {}
data "azurerm_subscription" "current" {}
data "crowdstrike_horizon_azure_client_id" "az" {
  tenant_id = data.azurerm_subscription.current.tenant_id
}

locals {
  tenant_id = data.azurerm_subscription.current.tenant_id
  client_id = var.azure_client_id != "" ? var.azure_client_id : data.crowdstrike_horizon_azure_client_id.az.client_id

  app_roles = [
    "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30", # Application.Read.All (Role)
    "5b567255-7703-4780-807c-7be8301ae99b", # Group.Read.All (Role)
    "246dd0d5-5bd0-4def-940b-0421030a5b68", # Policy.Read.All (Role)
    "230c1aed-a721-4c5d-9cb4-a90514e508ef", # Reports.Read.All (Role)
    "483bed4a-2ad3-4361-a73b-c83ccdbdc53c", # RoleManagement.Read.Directory (Role)
    "df021288-bdef-4463-88db-98f22de89214"  # User.Read.All (Role)    
  ]
}

# Register account with CrowdStrike
resource "crowdstrike_horizon_azure_account" "account" {
  tenant_id       = local.tenant_id
  subscription_id = var.use_azure_management_group ? var.default_subscription_id : ""
  # API expects boolean value here, not the actual subscription ID. 
  # If no service principal exists, the provider would create one.
  # This would not be needed after migration to the new auth design.
  default_subscription_id = var.use_azure_management_group
  is_commercial           = var.is_commercial
}

# Register management group if enabled
resource "crowdstrike_horizon_azure_management_group" "management_group" {
  count                   = var.use_azure_management_group ? 1 : 0
  tenant_id               = local.tenant_id
  default_subscription_id = var.default_subscription_id

  provisioner "local-exec" {
    command = "az rest --method post --url '/providers/Microsoft.Authorization/elevateAccess?api-version=2016-07-01'"
  }
  depends_on = [crowdstrike_horizon_azure_account.account]
}

# Create service principal
resource "azuread_service_principal" "sp" {
  client_id                    = local.client_id
  app_role_assignment_required = false
}

# Get Microsoft Graph Service Principal
data "azuread_service_principal" "msgraph" {
  display_name = "Microsoft Graph"
}

# Assign application roles
resource "azuread_app_role_assignment" "app_roles" {
  count               = length(local.app_roles)
  principal_object_id = azuread_service_principal.sp.object_id
  resource_object_id  = data.azuread_service_principal.msgraph.object_id
  app_role_id         = local.app_roles[count.index]
}

# Associate object_id ID with tenant in CrowdStrike
resource "crowdstrike_horizon_azure_client_id" "cs-client" {
  tenant_id = local.tenant_id
  client_id = local.client_id
  object_id = azuread_service_principal.sp.object_id

  depends_on = [crowdstrike_horizon_azure_account.account]
}
