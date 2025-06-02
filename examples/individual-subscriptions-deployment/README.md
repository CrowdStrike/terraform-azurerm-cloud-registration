# FCS Single Account Registration (Multi-Region with Custom Providers)

This example demonstrates how to register specific subscriptions with CrowdStrike Falcon Cloud Security (FCS).

## Features Enabled

- Asset Inventory

## Prerequisites

1. [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) installed
2. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) installed
3. CrowdStrike API credentials (see [Pre-requisites](../../README.md#pre-requisites) for details)

## Deploy

1. Login into the Azure tenant you want to register
```sh
az login -t "<tenant ID>"
```

2. Set required environment variables:
```sh
export TF_VAR_falcon_client_id=<your Falcon API client ID>
export TF_VAR_falcon_client_secret=<your Falcon API client secret>
export TF_VAR_cs_infra_subscription_id=<your subscription ID where global infrastructure resources will be deployed>
export TF_VAR_location=<Azure location where global resources will be deployed>

# List of specific Azure subscription IDs to monitor with CrowdStrike Falcon Cloud Security. Use this for targeted monitoring of individual subscriptions.
export TF_VAR_subscription_ids='["<subscription 1>", "<subscription 2>", ...]'
```

3. Initialize and apply Terraform:
```sh
terraform init
terraform apply
```

Enter `yes` at command prompt to apply


## Destroy

To teardown and remove all resources created by this example:

```sh
terraform destroy -auto-approve
```
