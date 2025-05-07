variable "tenant_id" {
  type        = string
  default     = ""
  description = "Azure tenant ID (optional - will be retrieved from current client config if not provided)"

  validation {
    condition     = var.tenant_id == "" || can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.tenant_id))
    error_message = "The tenant_id must be a valid UUID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}

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

variable "falcon_cid" {
  type        = string
  description = "Falcon CID"

  validation {
    condition     = can(regex("^[0-9a-f]{32}$", var.falcon_cid))
    error_message = "The tenant_id must be a valid KUID in the format XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX."
  }
}

variable "falcon_client_id" {
  type        = string
  description = "Client ID for the Falcon API"
}

variable "falcon_client_secret" {
  type        = string
  description = "Client secret for the Falcon API"
}

variable "falcon_url" {
  type        = string
  default     = "api.crowdstrike.com"
  description = "Falcon cloud API url"
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

variable "cs_infrastructure_subscription_id" {
  type        = string
  description = "Azure subscription ID that will host CrowdStrike infrastructure"

  validation {
    condition     = can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.cs_infrastructure_subscription_id))
    error_message = "The infrastructure subscription ID must be a valid UUID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
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

variable "resource_name_prefix" {
  description = "The prefix to be added to the resource name."
  default     = ""
  type        = string
}

variable "resource_name_suffix" {
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
