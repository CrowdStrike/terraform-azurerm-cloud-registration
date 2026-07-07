variable "account_type" {
  type        = string
  default     = "commercial"
  description = "Account type can be either 'commercial' or 'gov'"
  validation {
    condition     = var.account_type == "commercial" || var.account_type == "gov"
    error_message = "must be either 'commercial' or 'gov'"
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

variable "falcon_client_id" {
  type        = string
  sensitive   = true
  default     = ""
  description = "Falcon API client ID. Required when `enable_dspm` or `enable_vulnerability_scanning` is set to `true`."

  validation {
    condition     = !(var.enable_dspm || var.enable_vulnerability_scanning) || (length(var.falcon_client_id) == 32 && can(regex("^[a-fA-F0-9]+$", var.falcon_client_id)))
    error_message = "'falcon_client_id' is required when 'enable_dspm' or 'enable_vulnerability_scanning' is set to true and must be a 32-character hexadecimal string. Please use the Falcon console to generate a new API key/secret pair with appropriate scopes."
  }
}

variable "falcon_client_secret" {
  type        = string
  sensitive   = true
  default     = ""
  description = "Falcon API client secret. Required when `enable_dspm` or `enable_vulnerability_scanning` is set to `true`."

  validation {
    condition     = !(var.enable_dspm || var.enable_vulnerability_scanning) || (length(var.falcon_client_secret) == 40 && can(regex("^[a-zA-Z0-9]+$", var.falcon_client_secret)))
    error_message = "'falcon_client_secret' is required when 'enable_dspm' or 'enable_vulnerability_scanning' is set to true and must be a 40-character alphanumeric string. Please use the Falcon console to generate a new API key/secret pair with appropriate scopes."
  }
}

variable "falcon_ip_addresses" {
  type        = list(string)
  default     = []
  description = "List of CrowdStrike Falcon service IP addresses to be allowed in network security configurations. Refer to https://falcon.crowdstrike.com/documentation/page/re07d589 for the IP address list specific to your Falcon cloud region. Required when `enable_realtime_visibility` is set to `true`."

  validation {
    condition     = alltrue([for ip in var.falcon_ip_addresses : can(cidrhost("${ip}${strcontains(ip, "/") ? "" : "/32"}", 0))])
    error_message = "All entries must be valid IPv4 addresses or CIDR blocks (e.g. 1.2.3.4 or 10.0.0.0/8)."
  }
}

variable "cs_infra_subscription_id" {
  type        = string
  default     = ""
  description = "Azure subscription ID where CrowdStrike infrastructure resources, such as Event Hubs, will be deployed. This subscription must be accessible with the current credentials. Required when `enable_realtime_visibility` is set to `true`."

  validation {
    condition     = var.cs_infra_subscription_id == "" || can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.cs_infra_subscription_id))
    error_message = "The infrastructure subscription ID must be a valid UUID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}

variable "location" {
  description = "Azure location (region) where global resources such as role definitions and event hub will be deployed. These tenant-wide resources only need to be created once regardless of how many subscriptions are monitored."
  default     = "westus"
  type        = string

  validation {
    condition     = length(var.location) > 0
    error_message = "Location must not be an empty string"
  }
}

variable "microsoft_graph_permission_ids" {
  description = "Optional list of Microsoft Graph permission IDs to assign to the service principal. If provided, these will replace the default permissions."
  type        = list(string)
  default     = null

  validation {
    condition     = var.microsoft_graph_permission_ids == null ? true : alltrue([for id in coalesce(var.microsoft_graph_permission_ids, []) : can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", id))])
    error_message = "All Microsoft Graph permission IDs must be valid UUIDs in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}

variable "enable_realtime_visibility" {
  description = "Controls whether to enable Real Time Visibility and Detection feature for CrowdStrike Falcon Cloud Security in Azure."
  type        = bool
  default     = false
}

variable "log_ingestion_settings" {
  description = "Configuration settings for log ingestion. Controls whether to enable Azure Activity Logs and Microsoft Entra ID logs collection via Event Hubs, and allows using either newly created Event Hubs or existing ones."
  type = object({
    activity_log = optional(object({
      enabled = bool
      existing_eventhub = optional(object({
        use                          = bool
        eventhub_resource_id         = optional(string, "")
        eventhub_consumer_group_name = optional(string, "")
      }), { use = false })
    }), { enabled = true })
    entra_id_log = optional(object({
      enabled = bool
      existing_eventhub = optional(object({
        use                          = bool
        eventhub_resource_id         = optional(string, "")
        eventhub_consumer_group_name = optional(string, "")
      }), { use = false })
    }), { enabled = true })
  })
  default = {}
}

variable "enable_dspm" {
  description = "Controls whether to enable DSPM (Data Security Posture Management) for CrowdStrike Falcon Cloud Security in Azure."
  type        = bool
  default     = false

  validation {
    condition = !var.enable_dspm || (
      (length(var.agentless_scanning_locations) > 0 && length(var.agentless_scanning_locations_per_subscription) == 0) ||
      (length(var.agentless_scanning_locations_per_subscription) > 0 && length(var.agentless_scanning_locations) == 0)
    )
    error_message = "If DSPM is enabled either 'agentless_scanning_locations' or 'agentless_scanning_locations_per_subscription' must be provided."
  }
}

variable "enable_vulnerability_scanning" {
  description = "Controls whether to enable Vulnerability Scanning for CrowdStrike Falcon Cloud Security in Azure."
  type        = bool
  default     = false

  validation {
    condition = !var.enable_vulnerability_scanning || (
      (length(var.agentless_scanning_locations) > 0 && length(var.agentless_scanning_locations_per_subscription) == 0) ||
      (length(var.agentless_scanning_locations_per_subscription) > 0 && length(var.agentless_scanning_locations) == 0)
    )
    error_message = "If vulnerability scanning is enabled either 'agentless_scanning_locations' or 'agentless_scanning_locations_per_subscription' must be provided."
  }
}

variable "agentless_scanning_locations" {
  description = "List of Azure locations (regions) where agentless scanning will be deployed."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for loc in var.agentless_scanning_locations : (length(loc) > 0)])
    error_message = "All agentless scanning locations must be non-empty strings."
  }
}

variable "agentless_scanning_locations_per_subscription" {
  description = "Map of Azure subscription IDs to lists of locations (regions) where agentless scanning will be deployed per subscription."
  type        = map(list(string))
  default     = {}

  validation {
    condition     = alltrue([for id, _ in var.agentless_scanning_locations_per_subscription : can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", id))])
    error_message = "All keys in 'agentless_scanning_locations_per_subscription' must be valid subscription UUIDs in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
  validation {
    condition     = alltrue([for _, locs in var.agentless_scanning_locations_per_subscription : alltrue([for loc in locs : (length(loc) > 0)])])
    error_message = "All locations in 'agentless_scanning_locations_per_subscription' must be non-empty strings."
  }
}

variable "agentless_scanning_custom_vnet_configuration" {
  description = "Per-region custom VNet configuration for agentless scanning. Keys are Azure region names; values contain scanners_subnet_id and clones_subnet_id."
  type = map(object({
    scanners_subnet_id = string
    clones_subnet_id   = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for region, config in var.agentless_scanning_custom_vnet_configuration :
      (length(config.scanners_subnet_id) > 0 && length(config.clones_subnet_id) > 0)
    ])
    error_message = "Each custom VNet configuration entry must have non-empty 'scanners_subnet_id' and 'clones_subnet_id'."
  }
  validation {
    condition = length(var.agentless_scanning_custom_vnet_configuration) == 0 || length(
      setsubtract(
        setunion(toset(var.agentless_scanning_locations), toset(flatten(values(var.agentless_scanning_locations_per_subscription)))),
        toset(keys(var.agentless_scanning_custom_vnet_configuration))
      )
    ) == 0
    error_message = "If 'agentless_scanning_custom_vnet_configuration' is specified, all locations in 'agentless_scanning_locations' and 'agentless_scanning_locations_per_subscription' must have a corresponding entry."
  }
}

variable "agentless_scanning_deploy_nat_gateway" {
  description = "Indicates Agentless Scanning environment will be deployed with NAT Gateway."
  default     = true
  type        = bool
}

variable "key_vault_allowed_ip_rules" {
  description = "Allowed IP rules (IPs or CIDR blocks) for restricting Key Vault access. If empty all network access will be allowed."
  type        = list(string)
  default     = []
}

variable "resource_prefix" {
  description = "Prefix to be added to all created resource names for identification."
  default     = ""
  type        = string

  validation {
    condition     = length(var.resource_prefix) + length(var.resource_suffix) <= 10
    error_message = "The combined length of resource_prefix and resource_suffix must be 10 characters or less."
  }
  validation {
    condition     = var.resource_prefix == "" || can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.resource_prefix))
    error_message = "resource_prefix can only contain letters, numbers, and hyphens, and must start with a letter."
  }
}

variable "resource_suffix" {
  description = "Suffix to be added to all created resource names for identification."
  default     = ""
  type        = string

  validation {
    condition     = var.resource_suffix == "" || can(regex("^[a-zA-Z0-9-]*[a-zA-Z0-9]$", var.resource_suffix))
    error_message = "resource_suffix can only contain letters, numbers, and hyphens, and must end with a letter or number."
  }
}

variable "env" {
  description = "Environment label (for example, prod, stag, dev) used for resource naming and tagging. Helps distinguish between different deployment environments. Limited to 4 alphanumeric characters for compatibility with resource naming restrictions."
  default     = "prod"
  type        = string

  validation {
    condition     = var.env == "" || (length(var.env) <= 4 && can(regex("^[0-9a-zA-Z]*$", var.env)))
    error_message = "The 'env' must only contain alphanumeric characters and has a limit of 4 characters."
  }
}

variable "service_principal_object_id" {
  description = "Optional object ID of an existing service principal. If provided, a new service principal will not be created and this existing one will be used instead."
  type        = string
  default     = ""

  validation {
    condition     = var.service_principal_object_id == "" || can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.service_principal_object_id))
    error_message = "The service principal object ID must be a valid UUID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}

variable "azure_client_id" {
  description = "Optional Azure client ID for the service principal. If not provided, will use the client_id from the CrowdStrike tenant registration."
  type        = string
  default     = ""

  validation {
    condition     = var.azure_client_id == "" || can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.azure_client_id))
    error_message = "The azure client ID must be a valid UUID in the format XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
  }
}

variable "tags" {
  description = "Map of tags to be applied to all resources created by this module. Default includes the CrowdStrike vendor tag."
  default = {
    CSTagVendor : "CrowdStrike"
  }
  type = map(string)

  validation {
    condition     = length(var.tags) <= 45
    error_message = "The tags map cannot contain more than 45 entries."
  }
}
