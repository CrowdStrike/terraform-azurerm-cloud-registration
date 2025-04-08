# CrowdStrike API Credentials
variable "cs_client_id" {
  type        = string
  description = "CrowdStrike API client ID"
  sensitive   = true
}

variable "cs_client_secret" {
  type        = string
  description = "CrowdStrike API client secret"
  sensitive   = true
}

# Azure Identity Configuration
variable "tenant_id" {
  type        = string
  default     = ""
  description = "Azure tenant ID. If not provided, will use the current Azure context"
}

variable "azure_client_id" {
  type        = string
  description = "Client ID of CrowdStrike's multi-tenant app (will be retrieved from CrowdStrike if not provided)"
}

# Azure Subscription Configuration
variable "use_azure_management_group" {
  type        = bool
  default     = false
  description = "Set to true to enable management group level access"
}

variable "default_subscription_id" {
  type        = string
  default     = ""
  description = "Default subscription ID, required when use_azure_management_group = true"
}

variable "subscription_ids" {
  type        = list(string)
  description = "List of Azure subscription IDs to monitor"
  default     = []

  validation {
    condition     = alltrue([for id in var.subscription_ids : can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", id))])
    error_message = "All subscription IDs must be valid UUIDs."
  }
}

# Environment Configuration
variable "is_commercial" {
  type        = bool
  default     = false
  description = "Is the account commercial? Only applicable when you're in the GovCloud Falcon environment"
}

# Input Validation
resource "null_resource" "validate_inputs" {
  lifecycle {
    precondition {
      condition     = var.use_azure_management_group || length(var.subscription_ids) > 0
      error_message = "At least one subscription ID must be provided when not using management groups."
    }

    precondition {
      condition     = !var.use_azure_management_group || var.default_subscription_id != ""
      error_message = "default_subscription_id is required when use_azure_management_group is true."
    }
  }
}
