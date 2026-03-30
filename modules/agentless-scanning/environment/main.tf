locals {
  environment       = var.env == "" ? "" : "-${var.env}"
  key_vault_uniq_id = substr(md5("${data.azurerm_client_config.current.subscription_id}${var.resource_group_name}CrowdStrikeScanningKeyVault"), 0, 18)

  # Locations that do NOT have custom VNet configuration — these need the scanning-region module
  managed_vnet_locations = toset([
    for loc in var.agentless_scanning_locations :
    loc if !contains(keys(var.agentless_scanning_custom_vnet_configuration), loc)
  ])

  # Resolve clones subnet ID per location: custom or module-created
  clones_subnet_id_per_location = {
    for loc in var.agentless_scanning_locations :
    loc => contains(keys(var.agentless_scanning_custom_vnet_configuration), loc) ? var.agentless_scanning_custom_vnet_configuration[loc].clones_subnet_id : module.scanning_region[loc].clones_subnet_id
  }
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azurerm_user_assigned_identity" "scanner" {
  location            = data.azurerm_resource_group.this.location
  name                = "${var.resource_prefix}id-csscanning${local.environment}${var.resource_suffix}"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# tflint-ignore: azurerm_resources_missing_prevent_destroy
resource "azurerm_key_vault" "client_credentials" {
  name                       = "kv-cs-${local.key_vault_uniq_id}"
  location                   = data.azurerm_resource_group.this.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  rbac_authorization_enabled = true
  purge_protection_enabled   = false

  network_acls {
    bypass         = "AzureServices"
    default_action = length(var.key_vault_allowed_ip_rules) > 0 ? "Deny" : "Allow"
    ip_rules       = var.key_vault_allowed_ip_rules
  }

  tags = merge(var.tags, {
    CSTagResourceType = "KeyVault"
  })
}

resource "azurerm_private_endpoint" "key_vault" {
  for_each = toset(var.agentless_scanning_locations)

  name                = "${var.resource_prefix}pep-csscanning-vault${local.environment}-${each.key}${var.resource_suffix}"
  location            = each.key
  resource_group_name = var.resource_group_name
  subnet_id           = local.clones_subnet_id_per_location[each.key]

  private_service_connection {
    name                           = "${var.resource_prefix}plsc-csscanning-vault${local.environment}-${each.key}${var.resource_suffix}"
    private_connection_resource_id = azurerm_key_vault.client_credentials.id
    is_manual_connection           = false
    subresource_names              = ["Vault"]
  }

  tags = merge(var.tags, {
    CSTagResourceType = "VaultPrivateEndpoint"
  })
}

resource "azurerm_role_assignment" "key_vault_scanner_secrets_user" {
  scope                = azurerm_key_vault.client_credentials.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.scanner.principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "key_vault_terraform_secrets_officer" {
  scope                = azurerm_key_vault.client_credentials.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
  principal_type       = "ServicePrincipal"
}

# tflint-ignore: azurerm_resources_missing_prevent_destroy
resource "azurerm_key_vault_secret" "client_credentials" {
  name = "client-credentials"
  value = jsonencode({
    clientId     = var.falcon_client_id
    clientSecret = var.falcon_client_secret
  })
  key_vault_id = azurerm_key_vault.client_credentials.id
  content_type = "string"
  tags         = var.tags

  depends_on = [
    azurerm_key_vault.client_credentials,
    azurerm_role_assignment.key_vault_scanner_secrets_user,
    azurerm_role_assignment.key_vault_terraform_secrets_officer
  ]
}

# Deploy regional scanning resources only for locations without custom VNet
module "scanning_region" {
  for_each = local.managed_vnet_locations

  source = "./scanning-region"

  location            = each.value
  deploy_nat_gateway  = var.agentless_scanning_deploy_nat_gateway
  resource_group_name = var.resource_group_name
  resource_prefix     = var.resource_prefix
  resource_suffix     = var.resource_suffix
  env                 = var.env
  tags                = var.tags
}
