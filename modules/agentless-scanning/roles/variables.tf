variable "agentless_scanning_deploy_nat_gateway" {
  description = "Specifies if NAT gateway should be deployed."
  type        = bool
}

variable "agentless_scanning_host_subscription_id" {
  description = "If specified, this is a target subscription deployment. Target subscriptions receive a reduced set of resource group permissions."
  type        = string
  default     = ""
}

variable "agentless_scanning_principal_id" {
  type        = string
  description = "Principal ID of the CrowdStrike application registered in Entra ID. This ID is used for role assignments and access control."

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
  type        = string
  description = "Name of the resource group where CrowdStrike infrastructure resources will be deployed."

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "'resource_group_name' should be non-empty string."
  }
}

variable "resource_prefix" {
  description = "Prefix to be added to all created resource names for identification."
  default     = ""
  type        = string

  validation {
    condition     = length(var.resource_prefix) + length(var.resource_suffix) <= 10
    error_message = "The combined length of resource_prefix and resource_suffix must be 10 characters or less."
  }
  validation {
    condition     = var.resource_prefix == "" || can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.resource_prefix))
    error_message = "resource_prefix can only contain letters, numbers, and hyphens, and must start with a letter."
  }
}

variable "resource_suffix" {
  description = "Suffix to be added to all created resource names for identification."
  default     = ""
  type        = string

  validation {
    condition     = var.resource_suffix == "" || can(regex("^[a-zA-Z0-9-]*[a-zA-Z0-9]$", var.resource_suffix))
    error_message = "resource_suffix can only contain letters, numbers, and hyphens, and must end with a letter or number."
  }
}

