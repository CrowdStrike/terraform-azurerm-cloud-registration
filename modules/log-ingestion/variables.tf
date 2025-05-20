variable "management_group_ids" {
  type        = list(string)
  default     = []
  description = "List of Azure management group IDs to monitor for log ingestion"

  validation {
    condition     = alltrue([for id in var.management_group_ids : can(regex("^[a-zA-Z0-9-_]{1,90}$", id))])
    error_message = "Management group IDs must be 1-90 characters consisting of alphanumeric characters, hyphens, and underscores."
  }
}

variable "subscription_ids" {
  type        = list(string)
  default     = []
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
  description = "Azure subscription ID that will host CrowdStrike log ingestion infrastructure"

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
  description = "Custom label indicating the environment to be monitored (e.g., prod, staging, dev)"
  default     = "prod"
  type        = string
}

variable "location" {
  description = "Azure region where global resources (Role definitions, Event Hub, etc.) will be deployed. These tenant-wide resources only need to be created once regardless of how many subscriptions are monitored."
  default     = "westus"
  type        = string
}

variable "resource_prefix" {
  description = "Prefix to be added to all created resource names for identification"
  default     = ""
  type        = string
}

variable "resource_suffix" {
  description = "Suffix to be added to all created resource names for identification"
  default     = ""
  type        = string
}

variable "tags" {
  description = "Tags to be applied to all resources created by this module"
  default = {
    CSTagVendor : "CrowdStrike"
  }
  type = map(string)
}
