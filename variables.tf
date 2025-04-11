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

variable "crowdstrike_infrastructure_subscription_id" {
  type        = string
  description = "Azure subscription ID that will host CrowdStrike infrastructure"

  validation {
    condition     = can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.crowdstrike_infrastructure_subscription_id))
    error_message = "The infrastructure subscription ID must be a valid UUID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}

variable "azure_client_id" {
  type        = string
  default     = ""
  description = "Client ID of CrowdStrike's multi-tenant app"

  validation {
    condition     = var.azure_client_id == "" || can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.azure_client_id))
    error_message = "The azure_client_id must be a valid UUID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}

variable "custom_entra_id_permissions" {
  description = "Optional list of Microsoft Graph app role IDs to assign to the service principal (overrides default roles)"
  type        = list(string)
  default     = null

  validation {
    condition     = var.custom_entra_id_permissions == null ? true : alltrue([for id in coalesce(var.custom_entra_id_permissions, []) : can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", id))])
    error_message = "All Microsoft Graph permission IDs must be valid UUIDs in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}
