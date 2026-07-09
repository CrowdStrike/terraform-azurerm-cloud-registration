variable "deploy_nat_gateway" {
  description = "Indicates Agentless Scanning environment will be deployed with NAT Gateway."
  default     = true
  type        = bool
}

variable "location" {
  type        = string
  description = "Azure location (region) where subscription level scanning resources will be deployed"

  validation {
    condition     = length(var.location) > 0
    error_message = "Deployment location (region) must be a non-empty string."
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
