variable "azure_client_id" {
  type        = string
  description = "Client ID of CrowdStrike's multi-tenant app"

  validation {
    condition     = var.azure_client_id == "" || can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.azure_client_id))
    error_message = "The azure_client_id must be a valid UUID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}

variable "microsoft_graph_permission_ids" {
  description = "List of Microsoft Graph app role IDs to assign to the service principal"
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition     = alltrue([for id in var.microsoft_graph_permission_ids : can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", id))])
    error_message = "All Microsoft Graph permission IDs must be valid UUIDs in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}
