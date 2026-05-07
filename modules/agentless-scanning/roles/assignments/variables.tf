variable "role_definition_ids" {
  description = "Role definition resource IDs to assign."
  type = object({
    subscription_access  = string
    rg_access            = string
    rg_access_target     = string
    subscription_scanner = string
    custom_vnet_subnet   = string
  })
}

variable "agentless_scanning_principal_id" {
  description = "Principal ID of the CrowdStrike application for role assignments."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.agentless_scanning_principal_id))
    error_message = "'agentless_scanning_principal_id' must be a valid UUID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}

variable "agentless_scanner_identity_principal_id" {
  description = "Azure agentless scanning scanner managed identity ID."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.agentless_scanner_identity_principal_id))
    error_message = "'agentless_scanner_identity_principal_id' must be a valid UUID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group for RG-scoped assignments."
  type        = string

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "'resource_group_name' should be non-empty string."
  }
}

variable "is_host" {
  description = "Whether this is the host subscription (uses rg_access vs rg_access_target)."
  type        = bool
  default     = true
}

variable "custom_subnet_ids" {
  description = "Set of custom subnet IDs for VNet subnet role assignments."
  type        = set(string)
  default     = []
}
