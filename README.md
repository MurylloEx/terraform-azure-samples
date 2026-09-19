# Terraform Azure Samples

Terraform samples for provisioning common Microsoft Azure resources. These examples are based on Alan Rodrigues' Udemy Terraform course and are intended for learning and reference while exploring Infrastructure as Code on Azure.

Each numbered folder is a self-contained Terraform configuration you can initialize, plan, and apply independently. Samples progress from foundational building blocks (resource groups, budgets, storage) through networking and virtual machines to databases, queues, Function Apps, and a simple storage-processing pipeline.

## Prerequisites

- An active [Azure](https://azure.microsoft.com/) subscription
- [Terraform](https://www.terraform.io/) `~> 1.4`
- [Azure CLI](https://learn.microsoft.com/cli/azure/) (optional but useful for authentication and inspection)
- A service principal (or equivalent credentials) with permission to create resources in the target subscription

Most samples expect variables such as `azure_subscription_id`, `azure_tenant_id`, `azure_client_id`, `azure_client_secret`, `app_name`, and optionally `app_stage` / `azure_region`.

## Samples

| Sample | Description |
| --- | --- |
| [`01-resource-groups`](01-resource-groups) | Creates a tagged Azure resource group named from stage and application name. |
| [`02-consumption-budgets`](02-consumption-budgets) | Adds a resource-group consumption budget with a monitor action group and spend notification thresholds. |
| [`03-storage-account`](03-storage-account) | Provisions a Standard StorageV2 account with geo-redundant (GRS) replication. |
| [`04-blob-storage`](04-blob-storage) | Extends storage with a blob container and uploads a sample block blob (`Hello world!`). |
| [`05-static-site`](05-static-site) | Enables static website hosting on a storage account and publishes `index.html` / `404.html` to `$web`. |
| [`06-cdn-endpoint`](06-cdn-endpoint) | Fronts the static website with an Azure CDN profile and HTTPS-only endpoint (random unique name). |
| [`07-virtual-network`](07-virtual-network) | Creates a virtual network (`10.0.0.0/16`) with two subnets (`10.0.1.0/24` and `10.0.2.0/24`). |
| [`08-network-interface`](08-network-interface) | Adds private and public network interfaces plus a dynamic public IP on the VNet/subnets. |
| [`09-security-group`](09-security-group) | Defines a network security group (including an AllowRDP rule) and associates it with both subnets. |
| [`10-linux-vm`](10-linux-vm) | Deploys an Ubuntu 20.04 Linux VM with SSH key generation, NSG rules (SSH/HTTP/HTTPS/ICMP), and cloud-init Apache install. |
| [`11-vm-data-disk`](11-vm-data-disk) | Builds on the Linux VM sample by creating and attaching an 8 GB managed data disk. |
| [`12-cosmos-db`](12-cosmos-db) | Provisions a serverless Cosmos DB account (SQL API), database, and partitioned container. |
| [`13-mysql-db`](13-mysql-db) | Creates an Azure Database for MySQL Flexible Server and a `utf8mb4` database. |
| [`14-storage-queue`](14-storage-queue) | Creates a storage account and an Azure Storage Queue for asynchronous messaging. |
| [`15-function-app`](15-function-app) | Deploys a Linux Node.js Function App (consumption plan) with Application Insights, storage, and a deployment slot. |
| [`16-storage-pipeline`](16-storage-pipeline) | Combines source/destination blob containers with a Linux Function App and Application Insights for a storage pipeline pattern. |

## Usage

From any sample directory:

```bash
cd 01-resource-groups
terraform init
terraform plan
terraform apply
```

Pass credentials and naming variables via a `terraform.tfvars` file, environment variables, or CLI `-var` flags. Tear down resources when you are done:

```bash
terraform destroy
```

> **Note:** Several samples include example passwords or open network rules suitable only for learning environments. Do not reuse them in production.

## License

This project is licensed under the [MIT License](LICENSE). Copyright (c) 2023 Muryllo Pimenta.
