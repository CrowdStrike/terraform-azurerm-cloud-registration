variable "management_group_ids" {
  type        = list(string)
  default     = []
  description = "List of management group IDs to monitor"

  validation {
    condition     = alltrue([for id in var.management_group_ids : can(regex("^[a-zA-Z0-9-_]{1,90}$", id))])
    error_message = "Management group IDs must be 1-90 characters consisting of alphanumeric characters, hyphens, and underscores."
  }
}

variable "subscription_ids" {
  type        = list(string)
  default     = []
  description = "List of subscription IDs to monitor"

  validation {
    condition     = alltrue([for id in var.subscription_ids : can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", id))])
    error_message = "All subscription IDs must be valid UUIDs in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}

variable "app_service_principal_id" {
  type        = string
  description = "Service principal ID of Crowdstrike app to which all the roles will be assigned"

  validation {
    condition     = can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.app_service_principal_id))
    error_message = "The object_id must be a valid UUID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}

variable "falcon_ip_addresses" {
  type        = list(string)
  default     = []
  description = "List of CrowdStrike Falcon service IP addresses to be allowed in network security configurations. Refer to https://falcon.crowdstrike.com/documentation/page/re07d589/add-crowdstrike-ip-addresses-to-cloud-provider-allowlists-0 for the IP address list specific to your Falcon cloud region."

  validation {
    condition     = alltrue([for ip in var.falcon_ip_addresses : can(regex("^(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])(\\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9]))){3}$", ip))])
    error_message = "All IP addresses must be valid IPv4 address format."
  }
}

variable "cs_infra_subscription_id" {
  type        = string
  description = "Azure subscription ID that will host CrowdStrike infrastructure"

  validation {
    condition     = can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.cs_infra_subscription_id))
    error_message = "The infrastructure subscription ID must be a valid UUID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name that will host CrowdStrike infrastructure"
}

variable "activity_log_settings" {
  description = "Settings of realtime visibility for activity log"
  type = object({
    enabled = bool
    existing_eventhub = object({
      use                  = bool
      eventhub_resource_id = optional(string)
    })
  })
  default = {
    enabled = true
    existing_eventhub = {
      use                  = false
      eventhub_resource_id = ""
    }
  }
}

variable "entra_id_log_settings" {
  description = "Settings of realtime visibility for Entra ID log"
  type = object({
    enabled = bool
    existing_eventhub = object({
      use                  = bool
      eventhub_resource_id = optional(string)
    })
  })
  default = {
    enabled = true
    existing_eventhub = {
      use                  = false
      eventhub_resource_id = ""
    }
  }
}

variable "env" {
  description = "Custom label indicating the environment to be monitored, such as prod, stag or dev."
  default     = "prod"
  type        = string
}

variable "location" {
  description = "Azure location (aka region) where global resources (Role definitions, Event Hub, etc.) will be deployed. These tenant-wide resources only need to be created once regardless of how many subscriptions are monitored."
  default     = "westus"
  type        = string
}

variable "resource_prefix" {
  description = "The prefix to be added to the resource name."
  default     = ""
  type        = string
}

variable "resource_suffix" {
  description = "The suffix to be added to the resource name."
  default     = ""
  type        = string
}

variable "tags" {
  description = "Tags to be applied to all resources"
  default = {
    CSTagVendor : "Crowdstrike"
  }
  type = map(string)
}
