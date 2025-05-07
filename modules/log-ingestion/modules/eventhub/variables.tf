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

variable "activity_log_settings" {
  description = "Settings of realtime visibility for activity log"
  type = object({
    enabled = bool
    existing_eventhub = object({
      use = bool
    })
  })
  default = {
    enabled = true
    existing_eventhub = {
      use = false
    }
  }
}

variable "entra_id_log_settings" {
  description = "Settings of realtime visibility for Entra ID log"
  type = object({
    enabled = bool
    existing_eventhub = object({
      use = bool
    })
  })
  default = {
    enabled = true
    existing_eventhub = {
      use = false
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
