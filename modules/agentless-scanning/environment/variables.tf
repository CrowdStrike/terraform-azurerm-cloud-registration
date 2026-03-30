variable "agentless_scanning_deploy_nat_gateway" {
  description = "Indicates Agentless Scanning environment will be deployed with NAT Gateway."
  default     = true
  type        = bool
}

variable "agentless_scanning_locations" {
  type        = list(string)
  description = "List of Azure locations (regions) where scanning environment will be deployed."

  validation {
    condition     = alltrue([for loc in var.agentless_scanning_locations : (length(loc) > 0)])
    error_message = "All scanning locations must be non-empty strings."
  }
  validation {
    condition     = length(var.agentless_scanning_locations) > 0
    error_message = "Scanning locations must be a non-empty list."
  }
}

variable "agentless_scanning_custom_vnet_configuration" {
  description = "Per-region custom VNet configuration for agentless scanning. Keys are Azure region names; values contain scanners_subnet_id and clones_subnet_id."
  type = map(object({
    scanners_subnet_id = string
    clones_subnet_id   = string
  }))
  default = {}
}

variable "key_vault_allowed_ip_rules" {
  description = "Allowed IP rules (IPs or CIDR blocks) for restricting Key Vault access. If empty all network access will be allowed."
  type        = list(string)
  default     = []
}

variable "falcon_client_id" {
  type        = string
  sensitive   = true
  description = "Falcon API client ID."

  validation {
    condition     = length(var.falcon_client_id) == 32 && can(regex("^[a-fA-F0-9]+$", var.falcon_client_id))
    error_message = "'falcon_client_id' must be a 32-character hexadecimal string. Please use the Falcon console to generate a new API key/secret pair with appropriate scopes."
  }
}

variable "falcon_client_secret" {
  type        = string
  sensitive   = true
  description = "Falcon API client secret."

  validation {
    condition     = length(var.falcon_client_secret) == 40 && can(regex("^[a-zA-Z0-9]+$", var.falcon_client_secret))
    error_message = "'falcon_client_secret' must be a 40-character alphanumeric string. Please use the Falcon console to generate a new API key/secret pair with appropriate scopes."
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

variable "env" {
  description = "Environment label (for example, prod, stag, dev) used for resource naming and tagging. Helps distinguish between different deployment environments. Limited to 4 alphanumeric characters for compatibility with resource naming restrictions."
  default     = "prod"
  type        = string

  validation {
    condition     = var.env == "" || (length(var.env) <= 4 && can(regex("^[0-9a-zA-Z]*$", var.env)))
    error_message = "The 'env' must only contain alphanumeric characters and has a limit of 4 characters."
  }
}

variable "tags" {
  description = "Map of tags to be applied to all resources created by this module. Default includes the CrowdStrike vendor tag."
  default = {
    CSTagVendor : "CrowdStrike"
  }
  type = map(string)

  validation {
    condition     = length(var.tags) <= 45
    error_message = "The tags map cannot contain more than 45 entries."
  }
}
