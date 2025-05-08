variable "tenant_id" {
  type        = string
  default     = ""
  description = "Azure tenant ID for deployment. If not provided, it will be automatically retrieved from the current Azure client configuration."

  validation {
    condition     = var.tenant_id == "" || can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.tenant_id))
    error_message = "The tenant_id must be a valid UUID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}

variable "management_group_ids" {
  type        = list(string)
  default     = []
  description = "List of Azure management group IDs to monitor with CrowdStrike Falcon Cloud Security. All subscriptions within these management groups will be automatically discovered and monitored."

  validation {
    condition     = alltrue([for id in var.management_group_ids : can(regex("^[a-zA-Z0-9-_]{1,90}$", id))])
    error_message = "Management group IDs must be 1-90 characters consisting of alphanumeric characters, hyphens, and underscores."
  }
}

variable "subscription_ids" {
  type        = list(string)
  default     = []
  description = "List of specific Azure subscription IDs to monitor with CrowdStrike Falcon Cloud Security. Use this for targeted monitoring of individual subscriptions."

  validation {
    condition     = alltrue([for id in var.subscription_ids : can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", id))])
    error_message = "All subscription IDs must be valid UUIDs in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
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
  description = "Azure subscription ID where CrowdStrike infrastructure resources (such as Event Hubs) will be deployed. This subscription must be accessible with the current credentials."

  validation {
    condition     = can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.cs_infra_subscription_id))
    error_message = "The infrastructure subscription ID must be a valid UUID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}

variable "azure_client_id" {
  type        = string
  default     = ""
  description = "Client ID of CrowdStrike's multi-tenant application in Azure. This is typically provided by CrowdStrike and is used to establish the connection between Azure and Falcon Cloud Security."

  validation {
    condition     = var.azure_client_id == "" || can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.azure_client_id))
    error_message = "The azure_client_id must be a valid UUID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}

variable "env" {
  description = "Environment identifier used in resource naming and tagging. Examples include 'prod', 'dev', 'test', etc. Limited to 4 alphanumeric characters for compatibility with resource naming restrictions."
  default     = "prod"
  type        = string

  validation {
    condition     = can(regex("^[0-9a-zA-Z]{4}$", var.env))
    error_message = "The 'env' must only contain alphanumeric characters and be exactly 4 characters in length."
  }
}

variable "region" {
  description = "Azure region where global resources (Role definitions, Event Hub, etc.) will be deployed. These tenant-wide resources only need to be created once regardless of how many subscriptions are monitored."
  default     = "westus"
  type        = string
}

variable "custom_entra_id_permissions" {
  description = "Optional list of Microsoft Graph permission IDs to assign to the service principal. If provided, these will replace the default permissions. Must include 'Application.Read.All' (ID: 9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30) at minimum."
  type        = list(string)
  default     = null

  validation {
    condition     = var.custom_entra_id_permissions == null ? true : alltrue(concat([for id in coalesce(var.custom_entra_id_permissions, []) : can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", id))], [contains(var.custom_entra_id_permissions, "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30")]))
    error_message = "All Microsoft Graph permission IDs must be valid UUIDs in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX. 'Application.Read.All' permission must be included."
  }
}

variable "enable_realtime_visibility" {
  type        = bool
  default     = false
  description = "Enable real-time visibility by configuring log ingestion for Azure Activity Logs and Entra ID logs. This provides enhanced security monitoring capabilities."
}

variable "deploy_realtime_visibility_remediation_policy" {
  type        = bool
  default     = false
  description = "When 'enable_realtime_visibility' is true, this option deploys an Azure Policy at each management group to automatically configure activity log diagnostic settings for EventHub in subscriptions where these settings are missing. Note that diagnostic settings deployed by this policy will not be tracked or managed by Terraform."
}

variable "realtime_visibility_activity_log_settings" {
  description = "Configuration settings for Azure Activity Log ingestion when 'enable_realtime_visibility' is true. Allows using either a newly created Event Hub or an existing one."
  type = object({
    enabled = bool
    existing_eventhub = object({
      use                   = bool
      subscription_id       = optional(string)
      resource_group_name   = optional(string)
      namespace_name        = optional(string)
      name                  = optional(string)
      consumer_group_name   = optional(string)
      authorization_rule_id = optional(string)
    })
  })
  default = {
    enabled = true
    existing_eventhub = {
      use                   = false
      subscription_id       = ""
      resource_group_name   = ""
      namespace_name        = ""
      name                  = ""
      consumer_group_name   = ""
      authorization_rule_id = ""
    }
  }
}

variable "realtime_visibility_entra_id_log_settings" {
  description = "Configuration settings for Microsoft Entra ID (formerly Azure AD) log ingestion when 'enable_realtime_visibility' is true. Allows using either a newly created Event Hub or an existing one."
  type = object({
    enabled = bool
    existing_eventhub = object({
      use                   = bool
      subscription_id       = optional(string)
      resource_group_name   = optional(string)
      namespace_name        = optional(string)
      name                  = optional(string)
      consumer_group_name   = optional(string)
      authorization_rule_id = optional(string)
    })
  })
  default = {
    enabled = true
    existing_eventhub = {
      use                   = false
      subscription_id       = ""
      resource_group_name   = ""
      namespace_name        = ""
      name                  = ""
      consumer_group_name   = ""
      authorization_rule_id = ""
    }
  }
}

variable "resource_prefix" {
  description = "Prefix to add to all resource names created by this module. Useful for organization and to avoid naming conflicts when deploying multiple instances of this module."
  default     = ""
  type        = string
}

variable "resource_suffix" {
  description = "Suffix to add to all resource names created by this module. Useful for organization and to avoid naming conflicts when deploying multiple instances of this module."
  default     = ""
  type        = string
}

variable "tags" {
  description = "Map of tags to be applied to all resources created by this module. Default includes the CrowdStrike vendor tag."
  default = {
    CSTagVendor : "Crowdstrike"
  }
  type = map(string)
}
