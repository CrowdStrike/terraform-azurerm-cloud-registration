# CrowdStrike Falcon Cloud Security - Existing Service Principal Deployment

This example demonstrates how to deploy CrowdStrike Falcon Cloud Security for Azure when the Entra ID application registration is managed separately by an Identity team.

## Use Case

This deployment pattern is designed for organizations where:
- **Identity Team** manages Entra ID applications and service principals
- **Azure Deployment Team** manages Azure infrastructure and resources
- Organizational policies require separation of identity and infrastructure management

## Prerequisites

### Identity Team Tasks (Pre-deployment)

Before using this Terraform module, the Identity Team must complete the following steps:

1. **Register CrowdStrike tenant with Falcon platform** using the [Falcon console](https://falcon.crowdstrike.com)
   - Navigate to **Cloud Security** > **Registration** > **Azure**
   - Follow the tenant registration wizard
   - Falcon Console can optionally generate terraform.tfvars for the Azure team
2. **Create the service principal** in Azure AD/Entra ID
3. **Assign Microsoft Graph permissions** to the service principal (see detailed list below)
4. **Provide the Service Principal Object ID** to the Azure Deployment Team

### Required Microsoft Graph Permissions

The Identity Team must assign these Microsoft Graph Application permissions to the service principal:

- Application.Read.All (Role)
- GroupMember.Read.All (Role)
- Policy.Read.All (Role)
- Reports.Read.All (Role)
- RoleManagement.Read.Directory (Role)
- User.Read.All (Role)
- Domain.Read.All (Role)
- AuditLog.Read.All (Role)
- Device.Read.All (Role)

### Information Required from Identity Team

The Azure Deployment Team needs the following information:

- **Service Principal Object ID**: The Azure AD object ID of the CrowdStrike service principal

## Deployment Steps

### 1. Configure Variables

You can configure variables in two ways:

**Option A: Use Falcon Console (Recommended)**
1. Log in to the [CrowdStrike Falcon Console](https://falcon.crowdstrike.com)
2. Navigate to **Cloud Security** > **Registration** > **Azure**
3. Follow the setup wizard and select **Terraform** as deployment method
4. The console will generate a `terraform.tfvars` file with your specific configuration
5. Download and use this generated file

**Option B: Manual Configuration**
Copy the example variables file and customize for your environment:

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. Set Required Variables

At minimum, you must provide:

```hcl
# Service Principal from Identity Team
crowdstrike_service_principal_object_id = "12345678-1234-1234-1234-123456789012"

# Azure Configuration
cs_infra_subscription_id = "87654321-4321-4321-4321-210987654321"
subscription_ids = [
  "11111111-1111-1111-1111-111111111111",
  "22222222-2222-2222-2222-222222222222"
]
```

### 3. Deploy Infrastructure

```bash
terraform init
terraform plan
terraform apply
```