variable "subscription_id" {
  type        = string
  description = "Azure subscription ID hosting the Eventhub namespace"

  validation {
    condition     = can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.subscription_id))
    error_message = "The infrastructure subscription ID must be a valid UUID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name hosting the Eventhub namespace"
}

variable "eventhub_namespace_name" {
  type        = string
  description = "Eventhub namespace name"
}

variable "eventhub_name" {
  type        = string
  description = "Eventhub instance name"
}
