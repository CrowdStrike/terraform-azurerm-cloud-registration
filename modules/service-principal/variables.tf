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
  default = [
    "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30", # Application.Read.All (Role)
    "98830695-27a2-44f7-8c18-0c3ebc9698f6", # GroupMember.Read.All (Role)
    "246dd0d5-5bd0-4def-940b-0421030a5b68", # Policy.Read.All (Role)
    "230c1aed-a721-4c5d-9cb4-a90514e508ef", # Reports.Read.All (Role)
    "483bed4a-2ad3-4361-a73b-c83ccdbdc53c", # RoleManagement.Read.Directory (Role)
    "df021288-bdef-4463-88db-98f22de89214"  # User.Read.All (Role)
  ]
  nullable = false

  validation {
    condition     = alltrue([for id in var.microsoft_graph_permission_ids : can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", id))])
    error_message = "All Microsoft Graph permission IDs must be valid UUIDs in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}
