variable "management_group_id" {
  type        = string
  description = "Management group ID for MG-scoped role definitions."

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]{1,90}$", var.management_group_id))
    error_message = "'management_group_id' must be 1-90 characters consisting of alphanumeric characters, hyphens, and underscores."
  }
}

variable "agentless_scanning_deploy_nat_gateway" {
  description = "Specifies if NAT gateway should be deployed. When false, public IP permissions are included."
  type        = bool
  default     = true
}

variable "use_custom_subnets" {
  description = "Whether custom VNet subnets are used. When true, creates the custom VNet subnet access role."
  type        = bool
  default     = false
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

variable "role_actions" {
  description = "Role action definitions passed from the parent module."
  type = object({
    subscription_access_actions       = list(string)
    host_rg_access_actions            = list(string)
    target_rg_access_actions          = list(string)
    conditional_public_ip_actions     = list(string)
    subscription_scanner_actions      = list(string)
    subscription_scanner_data_actions = list(string)
    custom_vnet_subnet_actions        = list(string)
  })
}
