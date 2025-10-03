variable "falcon_client_id" {
  type        = string
  sensitive   = true
  default     = ""
  description = "Falcon API client ID."
  validation {
    condition     = length(var.falcon_client_id) == 32 && can(regex("^[a-fA-F0-9]+$", var.falcon_client_id))
    error_message = "falcon_client_id must be a 32-character hexadecimal string. Please use the Falcon console to generate a new API key/secret pair with appropriate scopes."
  }
}

variable "falcon_client_secret" {
  type        = string
  sensitive   = true
  description = "Falcon API client secret."
  validation {
    condition     = length(var.falcon_client_secret) == 40 && can(regex("^[a-zA-Z0-9]+$", var.falcon_client_secret))
    error_message = "falcon_client_secret must be a 40-character hexadecimal string. Please use the Falcon console to generate a new API key/secret pair with appropriate scopes."
  }
}

variable "falcon_ip_addresses" {
  type        = list(string)
  description = "List of CrowdStrike Falcon service IP addresses to be allowed in network security configurations. Refer to https://falcon.crowdstrike.com/documentation/page/re07d589 for the IP address list specific to your Falcon cloud region. Required when `enable_realtime_visibility` is set to `true`."

  validation {
    condition     = alltrue([for ip in var.falcon_ip_addresses : can(regex("^(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])(\\.((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9]))){3}$", ip))])
    error_message = "All IP addresses must be valid IPv4 address format."
  }
}

variable "cs_infra_subscription_id" {
  type        = string
  default     = ""
  description = "Azure subscription ID where CrowdStrike infrastructure resources, such as Event Hubs, will be deployed. This subscription must be accessible with the current credentials. Required when `enable_realtime_visibility` is set to `true`."

  validation {
    condition     = can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.cs_infra_subscription_id))
    error_message = "The infrastructure subscription ID must be a valid UUID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}

variable "location" {
  description = "Azure location (region) where global resources such as role definitions and event hub will be deployed. These tenant-wide resources only need to be created once regardless of how many subscriptions are monitored."
  default     = "westus"
  type        = string
}

variable "me" {
  type        = string
  default     = "unspecified"
  description = "The user running terraform"
}
