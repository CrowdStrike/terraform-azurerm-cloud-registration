variable "tenant_id" {
  type        = string
  default     = ""
  description = "Used to create a graph dependency, not needed when running the module independently"
}

variable "use_azure_management_group" {
  type        = bool
  default     = false
  description = "Set to `true` to enable automatic subscription discovery"
}

variable "subscription_ids" {
  type        = list(string)
  default     = []
  description = "List of subscription IDs to include"
}

variable "object_id" {
  type        = string
  default     = ""
  description = "Used to create a graph dependency, not needed when running the module independently"
}

variable "is_commercial" {
  type        = bool
  default     = false
  description = "Is the account commercial? Only applicable when you're in the GovCloud Falcon environment"
}

resource "null_resource" "validate_subscription_ids" {
  lifecycle {
    precondition {
      condition     = var.use_azure_management_group || length(var.subscription_ids) > 0
      error_message = "subscription_ids must not be empty when use_azure_management_group is false."
    }
  }
}