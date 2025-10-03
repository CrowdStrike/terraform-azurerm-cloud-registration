variable "subscription_ids" {
  type        = list(string)
  description = "List of Azure subscription IDs to monitor for log ingestion"

  validation {
    condition     = alltrue([for id in var.subscription_ids : can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", id))])
    error_message = "All subscription IDs must be valid UUIDs in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}

variable "app_service_principal_id" {
  type        = string
  description = "Service principal ID of CrowdStrike app to which all the roles will be assigned for log ingestion"

  validation {
    condition     = can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.app_service_principal_id))
    error_message = "The object_id must be a valid UUID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}

variable "falcon_ip_addresses" {
  type        = list(string)
  default     = []
  description = "List of CrowdStrike Falcon service IP addresses to be allowed in network security configurations for log ingestion. Refer to https://falcon.crowdstrike.com/documentation/page/re07d589/add-crowdstrike-ip-addresses-to-cloud-provider-allowlists-0 for the IP address list specific to your Falcon cloud region."

  validation {
    condition     = alltrue([for ip in var.falcon_ip_addresses : can(regex("^(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])(\\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9]))){3}$", ip))])
    error_message = "All IP addresses must be valid IPv4 address format."
  }
}

variable "cs_infra_subscription_id" {
  type        = string
  description = "Azure subscription ID where CrowdStrike infrastructure resources, such as Event Hubs, will be deployed. This subscription must be accessible with the current credentials."

  validation {
    condition     = can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.cs_infra_subscription_id))
    error_message = "The infrastructure subscription ID must be a valid UUID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Azure resource group name that will host CrowdStrike log ingestion infrastructure"
}

variable "activity_log_settings" {
  description = "Configuration settings for Azure Activity Log ingestion"
  type = object({
    enabled = bool
    existing_eventhub = optional(object({
      use                          = bool
      eventhub_resource_id         = optional(string, "")
      eventhub_consumer_group_name = optional(string, "")
    }), { use = false })
  })
  default = {
    enabled = true
  }
}

variable "entra_id_log_settings" {
  description = "Configuration settings for Microsoft Entra ID log ingestion"
  type = object({
    enabled = bool
    existing_eventhub = optional(object({
      use                          = bool
      eventhub_resource_id         = optional(string)
      eventhub_consumer_group_name = optional(string)
    }), { use = false })
  })
  default = {
    enabled = true
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

variable "location" {
  description = "Azure location (region) where global resources such as role definitions and event hub will be deployed. These tenant-wide resources only need to be created once regardless of how many subscriptions are monitored."
  default     = "westus"
  type        = string
}

variable "resource_prefix" {
  description = "Prefix to be added to all created resource names for identification"
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
  description = "Suffix to be added to all created resource names for identification"
  default     = ""
  type        = string

  validation {
    condition     = var.resource_suffix == "" || can(regex("^[a-zA-Z0-9-]*[a-zA-Z0-9]$", var.resource_suffix))
    error_message = "resource_suffix can only contain letters, numbers, and hyphens, and must end with a letter or number."
  }
}

variable "tags" {
  description = "Tags to be applied to all resources created by this module"
  default = {
    CSTagVendor : "CrowdStrike"
  }
  type = map(string)
}
