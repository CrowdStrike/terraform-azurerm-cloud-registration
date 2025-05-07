variable "resource_group_name" {
  type        = string
  description = "Resource group name hosting the Eventhub namespace"
}

variable "falcon_ip_addresses" {
  type        = list(string)
  default     = []
  description = "List of IPv4 addresses of Crowdstrike Falcon service. Please refer to https://falcon.crowdstrike.com/documentation/page/re07d589/add-crowdstrike-ip-addresses-to-cloud-provider-allowlists-0 for the IP address list of your Falcon region."

  validation {
    condition     = alltrue([for ip in var.falcon_ip_addresses : can(regex("^(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])(\\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9]))){3}$", ip))])
    error_message = "All IP addresses must be valid IPv4 address format."
  }
}

variable "feature_settings" {
  description = "Settings of feature modules"
  type = object({
    realtime_visibility_detection = object({
      enabled = bool
      activity_log = object({
        enabled                       = bool
        use_existing_event_hub        = bool
        event_hub_namespace_name      = optional(string)
        event_hub_subscription_id     = optional(string)
        event_hub_resource_group_name = optional(string)
        event_hub_consumer_group_name = optional(string)
        event_hub_name                = optional(string)
        deploy_remediation_policy     = bool
      })
      entra_id_log = object({
        enabled                       = bool
        use_existing_event_hub        = bool
        event_hub_namespace_name      = optional(string)
        event_hub_subscription_id     = optional(string)
        event_hub_resource_group_name = optional(string)
        event_hub_consumer_group_name = optional(string)
        event_hub_name                = optional(string)
      })
    })
  })
  default = {
    realtime_visibility_detection = {
      enabled = true
      activity_log = {
        enabled                       = true
        use_existing_event_hub        = false
        event_hub_namespace_name      = ""
        event_hub_subscription_id     = ""
        event_hub_resource_group_name = ""
        event_hub_consumer_group_name = ""
        event_hub_name                = ""
        deploy_remediation_policy     = true
      }
      entra_id_log = {
        enabled                       = true
        use_existing_event_hub        = false
        event_hub_namespace_name      = ""
        event_hub_subscription_id     = ""
        event_hub_resource_group_name = ""
        event_hub_consumer_group_name = ""
        event_hub_name                = ""
      }
    }
  }
}

variable "env" {
  description = "Custom label indicating the environment to be monitored, such as prod, stag or dev."
  default     = "prod"
  type        = string
}

variable "region" {
  description = "Azure region for the resources deployed in this solution."
  default     = "westus"
  type        = string
}

variable "prefix" {
  description = "The prefix to be added to the resource name."
  default     = ""
  type        = string
}

variable "suffix" {
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
