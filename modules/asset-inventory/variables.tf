variable "tenant_id" {
  type        = string
  default     = ""
  description = "Used to create a graph dependency, not needed when running the module independently"

  validation {
    condition     = var.tenant_id == "" || can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.tenant_id))
    error_message = "The tenant_id must be a valid UUID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}

variable "subscription_ids" {
  type        = list(string)
  default     = []
  description = "List of subscription IDs"

  validation {
    condition     = alltrue([for id in var.subscription_ids : can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", id))])
    error_message = "All subscription IDs must be valid UUIDs in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
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

variable "object_id" {
  type        = string
  description = "Service principal object_id to which all the roles will be assigned"

  validation {
    condition     = var.object_id == "" || can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.object_id))
    error_message = "The object_id must be a valid UUID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}
