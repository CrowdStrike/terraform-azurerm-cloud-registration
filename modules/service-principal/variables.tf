# App Registration Configuration
variable "azure_client_id" {
  type        = string
  default     = ""
  description = "Client ID of CrowdStrike's multi-tenant app (optional - will be retrieved from CrowdStrike if not provided)"
}

# Azure Configuration
variable "use_azure_management_group" {
  type        = bool
  default     = false
  description = "Set to `true` to enable automatic subscription discovery"
}

variable "default_subscription_id" {
  type        = string
  default     = ""
  description = "Default subscription ID, required when use_azure_management_group = true"
}

variable "is_commercial" {
  type        = bool
  default     = false
  description = "Is the account commercial? Only applicable when in GovCloud Falcon environment"
}

resource "null_resource" "validate_inputs" {
  lifecycle {
    precondition {
      condition     = !var.use_azure_management_group || var.default_subscription_id != ""
      error_message = "When using management groups, a default_subscription_id must be provided."
    }
  }
}