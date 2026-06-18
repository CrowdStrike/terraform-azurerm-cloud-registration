variable "scope_type" {
  description = "Where to create role definitions: 'mg' or 'subscription'."
  type        = string

  validation {
    condition     = contains(["mg", "subscription"], var.scope_type)
    error_message = "scope_type must be 'mg' or 'subscription'."
  }
}

variable "scope_id" {
  description = "The management group ID or subscription ID to scope definitions to."
  type        = string
}

variable "agentless_scanning_deploy_nat_gateway" {
  description = "Whether NAT gateway is deployed (affects rg_access permissions)."
  type        = bool
  default     = true
}

variable "input_enable_vulnerability_scanning" {
  description = "Whether vulnerability scanning is enabled (affects subscription_access and rg_access permissions)."
  type        = bool
  default     = false
}

variable "use_custom_subnets" {
  description = "Whether to create the custom VNet subnet role definition."
  type        = bool
  default     = false
}

variable "is_host" {
  description = "Whether this is the host subscription (determines rg_access permissions). Only relevant for subscription scope."
  type        = bool
  default     = true
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
    subscription_access_actions                 = list(string)
    vulnerability_scanning_subscription_actions = list(string)
    host_rg_access_actions                      = list(string)
    vulnerability_scanning_rg_actions           = list(string)
    target_rg_access_actions                    = list(string)
    conditional_public_ip_actions               = list(string)
    subscription_scanner_actions                = list(string)
    subscription_scanner_data_actions           = list(string)
    custom_vnet_subnet_actions                  = list(string)
    rg_scanner_actions                          = list(string)
  })
}
