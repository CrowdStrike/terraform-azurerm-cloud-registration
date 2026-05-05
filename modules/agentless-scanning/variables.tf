variable "deploy_resource_group" {
  description = "Indicates Agentless Scanning environment will be deployed with a new resource group."
  default     = true
  type        = bool
}

variable "agentless_scanning_deploy_nat_gateway" {
  description = "Indicates Agentless Scanning environment will be deployed with NAT Gateway."
  default     = true
  type        = bool
}

variable "agentless_scanning_host_subscription_id" {
  description = "If specified deploy as target subscription."
  type        = string
  default     = ""

  validation {
    condition     = var.agentless_scanning_host_subscription_id == "" || can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.agentless_scanning_host_subscription_id))
    error_message = "If 'agentless_scanning_host_subscription_id' is specified it must be a valid UUID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
  validation {
    condition     = var.agentless_scanning_host_subscription_id == "" || var.agentless_scanner_identity_principal_id != ""
    error_message = "If 'agentless_scanning_host_subscription_id' is specified 'agentless_scanner_identity_principal_id' must be set"
  }
  validation {
    condition = var.agentless_scanning_host_subscription_id == "" || (
      length(var.input_agentless_scanning_locations_per_subscription) == 0 ||
      alltrue([
        for sub_id, locations in var.input_agentless_scanning_locations_per_subscription :
        (length(
          setsubtract(
            toset(locations),
            toset(lookup(var.input_agentless_scanning_locations_per_subscription, var.agentless_scanning_host_subscription_id, []))
          )
        ) == 0)
      ])
    )
    error_message = "If 'agentless_scanning_host_subscription_id' is specified, each location in 'input_agentless_scanning_locations_per_subscription' must be a subset of the host subscription's locations."
  }
}

variable "agentless_scanner_identity_principal_id" {
  description = "Optional Azure agentless scanning host scanner managed identity ID. Required when 'scanning_host_subscription_id' is set."
  type        = string
  default     = ""

  validation {
    condition     = var.agentless_scanner_identity_principal_id == "" || can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.agentless_scanner_identity_principal_id))
    error_message = "If 'agentless_scanner_identity_principal_id' is specified it must be a valid UUID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}

variable "agentless_scanning_principal_id" {
  description = "Principal ID of the CrowdStrike application registered in Entra ID. This ID is used for role assignments and access control."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.agentless_scanning_principal_id))
    error_message = "'agentless_scanning_principal_id' must be a valid UUID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}

variable "agentless_scanning_custom_vnet_configuration" {
  description = "Per-region custom VNet configuration for agentless scanning. Keys are Azure region names; values contain scanners_subnet_id and clones_subnet_id."
  type = map(object({
    scanners_subnet_id = string
    clones_subnet_id   = string
  }))
  default = {}

  validation {
    condition = var.agentless_scanning_host_subscription_id != "" || length(var.agentless_scanning_custom_vnet_configuration) == 0 || length(
      setsubtract(toset(var.agentless_scanning_locations), toset(keys(var.agentless_scanning_custom_vnet_configuration)))
    ) == 0
    error_message = "If 'agentless_scanning_custom_vnet_configuration' is specified, all locations in 'agentless_scanning_locations' must have a corresponding entry."
  }
}

variable "agentless_scanning_locations" {
  type        = list(string)
  description = "List of Azure locations (regions) where scanning environment will be deployed."
  default     = []

  validation {
    condition     = alltrue([for loc in var.agentless_scanning_locations : (length(loc) > 0)])
    error_message = "All scanning locations must be non-empty strings."
  }
}

variable "input_agentless_scanning_locations_per_subscription" {
  description = "Map of Azure subscription IDs to lists of locations (regions) where agentless scanning will be deployed per subscription."
  type        = map(list(string))
  default     = {}
}

variable "input_enable_dspm" {
  description = "Controls whether to enable DSPM (Data Security Posture Management). Stored in scanning parameters policy."
  type        = bool
  default     = true
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
  default     = ""

  validation {
    condition     = var.deploy_resource_group || length(var.resource_group_name) > 0
    error_message = "If using existing resource group ('deploy_resource_group' is false), then 'resource_group_name' should be non-empty string."
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

variable "scanning_role_definition_ids" {
  description = "MG-scoped role definition resource IDs. When provided, skip creating per-subscription role definitions and only create assignments using these external IDs."
  type = object({
    subscription_access  = string
    rg_access            = string
    rg_access_target     = string
    subscription_scanner = string
    custom_vnet_subnet   = string
  })
  default = null
}

variable "management_group_scopes" {
  description = "Set of management group IDs to create MG-scoped role definitions for. When non-empty, role definitions are created at MG scope instead of per-subscription."
  type        = set(string)
  default     = []
}

variable "host_mg_id" {
  description = "Management group ID that the host subscription belongs to. Used to automatically wire MG-scoped role definitions for the host subscription."
  type        = string
  default     = null
}
