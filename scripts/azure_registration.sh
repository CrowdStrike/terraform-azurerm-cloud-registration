#!/bin/bash
# Azure CSPM Registration Script - New Registration Method
# Version: 2.0 (Production Ready)
# Supports: Batch subscription registration via new API endpoints

# Uncomment for debugging
# set -x

FALCON_CLOUD=eu-1

usage() {
    echo "
    Usage: $0

Registers Azure Subscriptions in Falcon CSPM using the new registration method.

Required arguments:
    -t, --tenant-id             Azure Tenant ID
    -i, --infra-subscription    Azure subscription ID where CrowdStrike infrastructure will be deployed
    -r, --infra-region          Azure region for infrastructure deployment (e.g., westus, westeurope)
    -n, --registration-name     Name for this registration
    -a, --api-client-id         CrowdStrike API client ID (required)

Optional arguments:
    -s, --subscription-ids      Comma-separated list of subscription IDs to register
    -m, --management-groups     Comma-separated list of management group IDs to register
    -d, --delete                Unregister Azure subscriptions
    --enable-ioa                Enable IOA (log ingestion) feature
    --enable-dspm               Enable DSPM (agentless scanning) feature
    --resource-prefix           Resource name prefix (default: cs)
    --resource-suffix           Resource name suffix
    --environment               Environment name (default: prod)
    --activity-log-eventhub     Activity log Event Hub ID (full resource ID)
    --activity-log-consumer     Activity log consumer group (default: \$Default)
    --entra-log-eventhub        Entra ID log Event Hub ID (full resource ID)
    --entra-log-consumer        Entra ID log consumer group (default: \$Default)

Help Options:
    -h  display this help message
"
    exit 1
}

die() {
  echo "Fatal error: $*" >&2
  exit 1
}

# Parse arguments
while [[ $# != 0 ]]; do
case "$1" in
    -s|--subscription-ids)
    if [[ -n "${2:-}" ]] ; then
      IFS=',' read -ra SUBSCRIPTION_IDS <<< "${2}"
      shift
    fi
    ;;
    -t|--tenant-id)
    if [[ -n "${2:-}" ]]; then
      TENANT_ID="${2}"
      shift
    fi
    ;;
    -i|--infra-subscription)
    if [[ -n "${2:-}" ]]; then
      INFRA_SUBSCRIPTION_ID="${2}"
      shift
    fi
    ;;
    -r|--infra-region)
    if [[ -n "${2:-}" ]]; then
      INFRA_REGION="${2}"
      shift
    fi
    ;;
    -n|--registration-name)
    if [[ -n "${2:-}" ]]; then
      REGISTRATION_NAME="${2}"
      shift
    fi
    ;;
    -m|--management-groups)
    if [[ -n "${2:-}" ]]; then
      IFS=',' read -ra MANAGEMENT_GROUP_IDS <<< "${2}"
      shift
    fi
    ;;
    -d|--delete)
    DELETE=true
    ;;
    --enable-ioa)
    ENABLE_IOA=true
    ;;
    --enable-dspm)
    ENABLE_DSPM=true
    ;;
    --resource-prefix)
    if [[ -n "${2:-}" ]]; then
      RESOURCE_PREFIX="${2}"
      shift
    fi
    ;;
    --resource-suffix)
    if [[ -n "${2:-}" ]]; then
      RESOURCE_SUFFIX="${2}"
      shift
    fi
    ;;
    --environment)
    if [[ -n "${2:-}" ]]; then
      ENVIRONMENT="${2}"
      shift
    fi
    ;;
    --activity-log-eventhub)
    if [[ -n "${2:-}" ]]; then
      ACTIVITY_LOG_EVENTHUB="${2}"
      shift
    fi
    ;;
    --activity-log-consumer)
    if [[ -n "${2:-}" ]]; then
      ACTIVITY_LOG_CONSUMER="${2}"
      shift
    fi
    ;;
    --entra-log-eventhub)
    if [[ -n "${2:-}" ]]; then
      ENTRA_LOG_EVENTHUB="${2}"
      shift
    fi
    ;;
    --entra-log-consumer)
    if [[ -n "${2:-}" ]]; then
      ENTRA_LOG_CONSUMER="${2}"
      shift
    fi
    ;;
    -a|--api-client-id)
    if [[ -n "${2:-}" ]]; then
      API_CLIENT_ID="${2}"
      shift
    fi
    ;;
    -h|--help)
    usage
    ;;
    --) # end argument parsing
    shift
    break
    ;;
    -*) # unsupported flags
    >&2 echo "ERROR: Unsupported flag: '${1}'"
    usage
    ;;
esac
shift
done

# Set defaults
RESOURCE_PREFIX="${RESOURCE_PREFIX:-cs}"
ENVIRONMENT="${ENVIRONMENT:-prod}"
MANAGEMENT_GROUP_IDS="${MANAGEMENT_GROUP_IDS:-[]}"
ACTIVITY_LOG_CONSUMER="${ACTIVITY_LOG_CONSUMER:-\$Default}"
ENTRA_LOG_CONSUMER="${ENTRA_LOG_CONSUMER:-\$Default}"

# Validation
if [[ -z "$FALCON_CLOUD" ]]; then
  die "Ensure variable FALCON_CLOUD is filled out"
fi

if [[ -z "$TENANT_ID" ]]; then
  die "Argument -t / --tenant-id was not provided"
fi

# Validate that at least one of subscriptions or management groups is provided
if [[ ${#SUBSCRIPTION_IDS[@]} -eq 0 && ${#MANAGEMENT_GROUP_IDS[@]} -eq 0 ]]; then
  die "Must provide either subscription IDs (-s) or management groups (-m) or both"
fi

if [[ "$DELETE" != true ]]; then
  if [[ -z "$INFRA_SUBSCRIPTION_ID" ]]; then
    die "Argument -i / --infra-subscription was not provided"
  fi
  if [[ -z "$INFRA_REGION" ]]; then
    die "Argument -r / --infra-region was not provided"
  fi
  if [[ -z "$REGISTRATION_NAME" ]]; then
    die "Argument -n / --registration-name was not provided"
  fi
  if [[ -z "$API_CLIENT_ID" ]]; then
    die "Argument -a / --api-client-id was not provided"
  fi
fi

# Validate UUID formats
validate_uuid() {
  local uuid="$1"
  if [[ ! "$uuid" =~ ^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$ ]]; then
    return 1
  fi
  return 0
}

if ! validate_uuid "$TENANT_ID"; then
  die "Invalid tenant ID format: ${TENANT_ID}"
fi

if [[ -n "$INFRA_SUBSCRIPTION_ID" ]] && ! validate_uuid "$INFRA_SUBSCRIPTION_ID"; then
  die "Invalid infrastructure subscription ID format: ${INFRA_SUBSCRIPTION_ID}"
fi

# Validate API client ID format (UUID or 32-char hex)
if [[ -n "$API_CLIENT_ID" ]]; then
  if ! validate_uuid "$API_CLIENT_ID" && [[ ! "$API_CLIENT_ID" =~ ^[0-9a-f]{32}$ ]]; then
    die "Invalid API client ID format: ${API_CLIENT_ID}. Must be UUID or 32-character hex string."
  fi
fi

# Set Falcon Cloud URL
case "${FALCON_CLOUD}" in
    us-1)      FALCON_CLOUD="api.crowdstrike.com";;
    us-2)      FALCON_CLOUD="api.us-2.crowdstrike.com";;
    eu-1)      FALCON_CLOUD="api.eu-1.crowdstrike.com";;
    gov-1)     FALCON_CLOUD="api.laggar.gcw.crowdstrike.com";;
    *)         die "Unrecognized option: ${FALCON_CLOUD}";;
esac

auth() {
  RESPONSE=$(curl -sX POST "https://${FALCON_CLOUD}/oauth2/token" \
      -H "accept: application/json" \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -d "client_id=${FALCON_CLIENT_ID}&client_secret=${FALCON_CLIENT_SECRET}")

  BEARER_TOKEN=$(jq -r ".access_token" <<< "$RESPONSE")

  if [[ "$BEARER_TOKEN" == null || -z "$BEARER_TOKEN" ]]; then
    die "Failed to authenticate: ${RESPONSE}, check API client and cloud region"
  fi

  echo "Successfully authenticated to: ${FALCON_CLOUD}"
}

register_azure() {
  # Build features array based on flags
  FEATURES='["iom"'
  if [[ "$ENABLE_IOA" == true ]]; then
    FEATURES="${FEATURES}"', "ioa"'
  fi
  FEATURES="${FEATURES}"']'

  # Convert SUBSCRIPTION_IDS array to JSON array
  SUBSCRIPTION_IDS_JSON=$(printf '%s\n' "${SUBSCRIPTION_IDS[@]}" | jq -R . | jq -s .)

  # Convert MANAGEMENT_GROUP_IDS array to JSON array
  if [[ ${#MANAGEMENT_GROUP_IDS[@]} -gt 0 ]]; then
    MANAGEMENT_GROUP_IDS_JSON=$(printf '%s\n' "${MANAGEMENT_GROUP_IDS[@]}" | jq -R . | jq -s .)
  else
    MANAGEMENT_GROUP_IDS_JSON="[]"
  fi

  # API client configuration - always customer created
  API_CLIENT_KEY_TYPE="customer"
  API_CLIENT_KEY_ID="$API_CLIENT_ID"

  BODY=$(cat <<EOF
{
  "resource": {
    "additional_properties": {
      "advancedSettingsTab": "customizeResourceNames",
      "apiConfigTab": 1,
      "deploymentStackHostOptions": [
        "${INFRA_SUBSCRIPTION_ID}"
      ],
      "existingApiClientId": "${API_CLIENT_ID}",
      "isAdminConsentGranted": true,
      "isAdminConsentVerified": true,
      "isApiClientRequired": true,
      "isDetectionsChecked": $([ "$ENABLE_IOA" == true ] && echo "true" || echo "false"),
      "isDspmChecked": $([ "$ENABLE_DSPM" == true ] && echo "true" || echo "false"),
      "isLimitOnboardingChecked": true,
      "showPrefix": $([ -n "$RESOURCE_PREFIX" ] && echo "true" || echo "false"),
      "showSuffix": $([ -n "$RESOURCE_SUFFIX" ] && echo "true" || echo "false"),
      "step": 5,
      "registrationStartTime": $(date +%s)000
    },
    "api_client_key_id": "${API_CLIENT_KEY_ID}",
    "api_client_key_type": "${API_CLIENT_KEY_TYPE}",
    "cs_infra_region": "${INFRA_REGION}",
    "cs_infra_subscription_id": "${INFRA_SUBSCRIPTION_ID}",
    "deployment_method": "terraform-native",
    "environment": "${ENVIRONMENT}",
    "management_group_ids": ${MANAGEMENT_GROUP_IDS_JSON},
    "microsoft_graph_permission_ids": [
      "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30",
      "98830695-27a2-44f7-8c18-0c3ebc9698f6",
      "246dd0d5-5bd0-4def-940b-0421030a5b68",
      "230c1aed-a721-4c5d-9cb4-a90514e508ef",
      "483bed4a-2ad3-4361-a73b-c83ccdbdc53c",
      "df021288-bdef-4463-88db-98f22de89214",
      "dbb9058a-0e50-45d7-ae91-66909b5d4664",
      "b0afded3-3588-46d8-8b3d-9842eff778da",
      "7438b122-aefc-4978-80ed-43db9fcc7715"
    ],
    "microsoft_graph_permission_ids_readonly": true,
    "primary_domain": "",
    "products": [
      {
        "product": "cspm",
        "features": ${FEATURES}
      }
    ],
    "resource_name_prefix": "${RESOURCE_PREFIX}",
    "resource_name_suffix": "${RESOURCE_SUFFIX}",
    "status": "complete",
    "subscription_ids": ${SUBSCRIPTION_IDS_JSON},
    "tags": {},
    "tenant_id": "${TENANT_ID}"$([ -n "$ACTIVITY_LOG_EVENTHUB" ] || [ -n "$ENTRA_LOG_EVENTHUB" ] && echo "," || echo "")
$(if [[ -n "$ACTIVITY_LOG_EVENTHUB" || -n "$ENTRA_LOG_EVENTHUB" ]]; then
echo "    \"event_hub_settings\": ["
if [[ -n "$ACTIVITY_LOG_EVENTHUB" ]]; then
echo "      {"
echo "        \"purpose\": \"activity_logs\","
echo "        \"event_hub_id\": \"${ACTIVITY_LOG_EVENTHUB}\","
echo "        \"consumer_group\": \"${ACTIVITY_LOG_CONSUMER}\""
echo "      }$([ -n "$ENTRA_LOG_EVENTHUB" ] && echo "," || echo "")"
fi
if [[ -n "$ENTRA_LOG_EVENTHUB" ]]; then
echo "      {"
echo "        \"purpose\": \"entra_logs\","
echo "        \"event_hub_id\": \"${ENTRA_LOG_EVENTHUB}\","
echo "        \"consumer_group\": \"${ENTRA_LOG_CONSUMER}\""
echo "      }"
fi
echo "    ]"
fi)
  }
}
EOF
)

  if [[ ${#SUBSCRIPTION_IDS[@]} -gt 0 ]]; then
    echo -e "\nRegistering ${#SUBSCRIPTION_IDS[@]} Azure Subscription(s) in one registration..."
    echo "Subscriptions: ${SUBSCRIPTION_IDS_JSON}"
  else
    echo -e "\nRegistering Azure Management Groups in one registration..."
    echo "Management Groups: ${MANAGEMENT_GROUP_IDS_JSON}"
  fi

  echo -e "\nPayload:"
  echo "$BODY" | jq .

  RESPONSE=$(curl -sX POST "https://${FALCON_CLOUD}/cloud-security-registration-azure/entities/registrations/v1" \
    -H "Authorization: bearer ${BEARER_TOKEN}" \
    -H "content-type: application/json" \
    -d "$BODY")

  echo -e "\nResponse:"
  echo "$RESPONSE" | jq .

  REGISTRATION_ID=$(jq -r '.resources[0].registration_id // .resource.registration_id // empty' <<< "$RESPONSE")

  if [[ -n "$REGISTRATION_ID" ]]; then
    echo -e "\n Registration successful! Registration ID: ${REGISTRATION_ID}"
    echo -e "\n Next Steps:"
    echo "1. Deploy Terraform resources in Azure"
    echo "2. Use the official CrowdStrike Terraform module:"
    echo "   https://github.com/CrowdStrike/terraform-azurerm-cloud-registration"
    echo "3. The module will automatically create service principal and assign roles"
    if [[ "$ENABLE_IOA" == true ]]; then
      echo "4. Event Hub resources will be created for log ingestion"
    fi
  else
    ERROR_MSG=$(jq -r '.errors[0].message // .error.message // "Unknown error"' <<< "$RESPONSE")
    echo -e "\n Registration failed: ${ERROR_MSG}"
    echo "Full response above for debugging"
    exit 1
  fi
}

unregister_azure() {
  echo -e "\nQuerying registration for tenant: ${TENANT_ID}"

  QUERY_RESPONSE=$(curl -sX GET "https://${FALCON_CLOUD}/cloud-security-registration-azure/entities/registrations/v1?tenant_id=${TENANT_ID}" \
    -H "Authorization: bearer ${BEARER_TOKEN}" \
    -H "accept: application/json")

  REGISTRATION_ID=$(jq -r '.resources[0].registration_id // empty' <<< "$QUERY_RESPONSE")

  if [[ -z "$REGISTRATION_ID" || "$REGISTRATION_ID" == "null" ]]; then
    echo "No registration found for tenant: ${TENANT_ID}"
    return
  fi

  echo "Found registration ID: ${REGISTRATION_ID}"
  echo "Unregistering Azure tenant: ${TENANT_ID}"

  RESPONSE=$(curl -sX DELETE "https://${FALCON_CLOUD}/cloud-security-registration-azure/entities/registrations/v1?tenant_ids=${TENANT_ID}" \
    -H "Authorization: bearer ${BEARER_TOKEN}" \
    -H "accept: application/json")

  echo -e "\n$RESPONSE" | jq .

  echo -e "\n Manual Cleanup Required:"
  echo "1. Delete service principal and app registration in Azure AD"
  echo "2. Remove role assignments from subscriptions/management groups"
  echo "3. Delete Event Hub resources if IOA was enabled"
  echo "4. Remove any custom role definitions"
}

main() {
  auth

  # Validate subscription IDs if provided
  if [[ ${#SUBSCRIPTION_IDS[@]} -gt 0 ]]; then
    for SUBSCRIPTION_ID in "${SUBSCRIPTION_IDS[@]}"; do
      # Validate subscription ID format (UUID)
      if ! validate_uuid "$SUBSCRIPTION_ID"; then
        echo "ERROR: Invalid subscription ID format: '$SUBSCRIPTION_ID'"
        echo "Subscription IDs must be valid UUIDs in format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
        exit 1
      fi
    done

    # Check for duplicate subscription IDs
    SORTED_IDS=($(printf '%s\n' "${SUBSCRIPTION_IDS[@]}" | sort))
    DUPLICATES=($(printf '%s\n' "${SORTED_IDS[@]}" | uniq -d))

    if [[ ${#DUPLICATES[@]} -gt 0 ]]; then
      echo "ERROR: Duplicate subscription IDs found:"
      printf '  - %s\n' "${DUPLICATES[@]}"
      die "Remove duplicate subscription IDs and try again"
    fi

    echo "Found ${#SUBSCRIPTION_IDS[@]} subscription(s) to process:"
    printf '  - %s\n' "${SUBSCRIPTION_IDS[@]}"

    # Validate that infra subscription is included in the registration list
    if [[ "$DELETE" != true ]]; then
      INFRA_FOUND=false
      for subscription in "${SUBSCRIPTION_IDS[@]}"; do
        if [[ "$subscription" == "$INFRA_SUBSCRIPTION_ID" ]]; then
          INFRA_FOUND=true
          break
        fi
      done

      if [[ "$INFRA_FOUND" != true ]]; then
        die "Infrastructure subscription ID '${INFRA_SUBSCRIPTION_ID}' must be included in the subscription list. The subscription hosting CrowdStrike infrastructure must be within the registration scope."
      fi

      echo "✓ Infrastructure subscription '${INFRA_SUBSCRIPTION_ID}' found in registration list"
    fi
  fi

  if [[ ${#MANAGEMENT_GROUP_IDS[@]} -gt 0 ]]; then
    echo "Found ${#MANAGEMENT_GROUP_IDS[@]} management group(s) to process:"
    printf '  - %s\n' "${MANAGEMENT_GROUP_IDS[@]}"
  fi

  if [[ "$DELETE" == true ]]; then
    # Delete mode: unregister entire tenant
    unregister_azure
  else
    # Register mode: register subscriptions or management groups
    register_azure
  fi
}

main