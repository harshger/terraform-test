# terraform-test# Azure Web Application Infrastructure

Deploys:
>
    1. VNet and Subnets
    2. Network Security Group
    3. Load Balancer
    4. Managed SQL Database
    5. Virtual Machine Scale Set

## Prerequisites

```
    Terraform (version >= 1.10.0)
    Azure CLI
    Azure subscription
    Azure service principal with required permissions
```

Create a **terraform.tfvars** file in the root directory with the following content

```bash
    subscription_id = "your-subscription-id"
    tenant_id       = "your-tenant-id"
    client_id       = "your-service-principal-client-id"
    client_secret   = "your-service-principal-client-secret"
```

## Deployment Steps

Initialize Terraform:

```bash
terraform init
```

Review the deployment plan:

```bash
terraform plan
```

Apply the configuration:

```bash
terraform apply
```

When prompted, type yes to confirm the deployment.

### Important Notes

```json

1. The SQL Server is deployed with private endpoint access only
2. VM Scale Set instances are accessible through the load balancer
3. All sensitive credentials are stored in Key Vault
4. The load balancer's public IP address will be shown in the outputs
```
SSH private key for VMs is stored in Key Vault

### Accessing Resources
After deployment, you can get important information using:

```bash
terraform output
```

This will show:

```json
Resource group name
Key Vault name and URI
SQL Server private endpoint IP
Load balancer public IP address
```

## Test

To test the connectivity, I have uploaded a Node.js test script using the VMSS Custom Script Extension. The script will start a Node.js server and connect to the database deployed in the private subnet.
