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
}

variable "resource_suffix" {
  description = "Suffix to be added to all created resource names for identification."
  default     = ""
  type        = string
}
