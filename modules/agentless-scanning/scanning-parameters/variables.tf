variable "agentless_scanning_principal_id" {
  description = "Principal ID of the CrowdStrike application registered in Entra ID. This ID is used for role assignments and access control."
  type        = string
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

variable "enable_dspm" {
  description = "Controls whether to enable DSPM (Data Security Posture Management)."
  type        = bool
}

variable "agentless_scanning_locations" {
  type        = list(string)
  description = "List of Azure locations (regions) where scanning environment will be deployed."

  validation {
    condition     = alltrue([for loc in var.agentless_scanning_locations : (length(loc) > 0)])
    error_message = "All scanning locations must be non-empty strings."
  }
}

variable "agentless_scanning_locations_per_subscription" {
  description = "Map of Azure subscription IDs to lists of locations (regions) where agentless scanning will be deployed per subscription."
  type        = map(list(string))

  validation {
    condition     = alltrue([for id, _ in var.agentless_scanning_locations_per_subscription : can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", id))])
    error_message = "All keys in 'agentless_scanning_locations_per_subscription' must be valid subscription UUIDs in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
  validation {
    condition     = alltrue([for _, locs in var.agentless_scanning_locations_per_subscription : alltrue([for loc in locs : (length(loc) > 0)])])
    error_message = "All locations in 'agentless_scanning_locations_per_subscription' must be non-empty strings."
  }
}

variable "agentless_scanning_host_subscription_id" {
  description = "Subscription ID of the host account where scanning resources are deployed."
  type        = string
}

variable "agentless_scanning_deploy_nat_gateway" {
  description = "Indicates Agentless Scanning environment will be deployed with NAT Gateway."
  type        = bool
}

variable "resource_prefix" {
  description = "Prefix to be added to all created resource names for identification."
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
  type        = string

  validation {
    condition     = var.resource_suffix == "" || can(regex("^[a-zA-Z0-9-]*[a-zA-Z0-9]$", var.resource_suffix))
    error_message = "resource_suffix can only contain letters, numbers, and hyphens, and must end with a letter or number."
  }
}

variable "env" {
  description = "Environment label (for example, prod, stag, dev) used for resource naming and tagging. Helps distinguish between different deployment environments. Limited to 4 alphanumeric characters for compatibility with resource naming restrictions."
  type        = string

  validation {
    condition     = var.env == "" || (length(var.env) <= 4 && can(regex("^[0-9a-zA-Z]*$", var.env)))
    error_message = "The 'env' must only contain alphanumeric characters and has a limit of 4 characters."
  }
}

variable "tags" {
  description = "Map of tags to be applied to all resources created by this module. Default includes the CrowdStrike vendor tag."
  type        = map(string)

  validation {
    condition     = length(var.tags) <= 45
    error_message = "The tags map cannot contain more than 45 entries."
  }
}
