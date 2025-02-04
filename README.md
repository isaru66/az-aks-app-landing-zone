# Azure Infrastructure with Terraform

This repository contains Terraform configurations for deploying a production-grade Azure infrastructure with AKS and supporting resources.

## Prerequisites

- Terraform >= 1.0.0
- Azure CLI >= 2.40.0
- Azure subscription with required permissions
- Azure AD admin group for AKS cluster administration

## Initial Setup and Authentication

### 1. Install Azure CLI
```bash
# For macOS using Homebrew
brew update && brew install azure-cli

# For Windows using PowerShell
winget install -e --id Microsoft.AzureCLI

# For Ubuntu/Debian
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### 2. Azure Authentication and Subscription Setup
```bash
# Login to Azure
az login

# List all subscriptions
az account list --output table

# Set your desired subscription
az account set --subscription="SUBSCRIPTION_ID"

# Verify current subscription
az account show
```

### 3. Required Permissions and Credentials
```bash
# Get your user object ID (needed for some configurations)
az ad signed-in-user show --query id -o tsv

# Create Azure AD Group for AKS Admins (if not exists)
az ad group create --display-name "AKS-Cluster-Admins" --mail-nickname "aks-cluster-admins"

# Get the Azure AD Group Object ID (for admin_group_object_ids)
az ad group show --group "AKS-Cluster-Admins" --query id -o tsv

# Assign required roles
az role assignment add --assignee "AKS-Cluster-Admins" --role "Azure Kubernetes Service Cluster Admin Role"
```

### 4. Create Service Principal for Terraform (Optional but recommended)
```bash
# Create Service Principal
SP_JSON=$(az ad sp create-for-rbac --name "terraform-sp" --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID")

# Extract credentials
CLIENT_ID=$(echo $SP_JSON | jq -r .appId)
CLIENT_SECRET=$(echo $SP_JSON | jq -r .password)
TENANT_ID=$(echo $SP_JSON | jq -r .tenant)

# Store these values securely - you'll need them for Terraform authentication
echo "Client ID: $CLIENT_ID"
echo "Client Secret: $CLIENT_SECRET"
echo "Tenant ID: $TENANT_ID"
```

### 5. Configure Azure Storage for Terraform State
```bash
# Create Resource Group for state storage
az group create --name terraform-state-rg --location eastus

# Create Storage Account (replace [UNIQUE] with a unique identifier)
az storage account create \
  --name tfstate[UNIQUE] \
  --resource-group terraform-state-rg \
  --sku Standard_LRS \
  --encryption-services blob

# Create Blob Container
az storage container create \
  --name tfstate \
  --account-name tfstate[UNIQUE]

# Get Storage Account Key
ACCOUNT_KEY=$(az storage account keys list --resource-group terraform-state-rg --account-name tfstate[UNIQUE] --query '[0].value' -o tsv)
```

## Infrastructure Components

- Resource Groups for logical resource organization
- Virtual Network with custom subnet configuration
- Network Security Groups with predefined security rules
- Private AKS cluster with:
  - Azure Linux (CBL-Mariner) as the node OS
  - Azure CNI networking
  - Azure network policy
  - System and workload node pools with autoscaling
  - Multi-zone deployment for high availability
  - Workload Identity and OIDC support
  - Microsoft Defender integration
- Private DNS Zones for internal service communication

## Module Structure

```
.
├── modules/
│   ├── aks/                    # Azure Kubernetes Service configuration
│   ├── network_security_group/ # NSG rules and configurations
│   ├── private_dns_zone/       # Private DNS zone settings
│   ├── resource_group/         # Resource group management
│   ├── subnet/                 # Subnet configurations
│   └── virtual_network/        # VNet and networking setup
├── main.tf                     # Main infrastructure configuration
├── providers.tf                # Provider configuration
├── variables.tf                # Input variables
├── outputs.tf                  # Output values
└── terraform.tfvars           # Variable values
```

## Getting Started

1. Configure Azure authentication:
```bash
az login
az account set --subscription="SUBSCRIPTION_ID"
```

2. Initialize the backend:
```bash
az group create --name terraform-state-rg --location eastus
az storage account create --name tfstate[UNIQUE] --resource-group terraform-state-rg --sku Standard_LRS
az storage container create --name tfstate --account-name tfstate[UNIQUE]
```

3. Initialize Terraform:
```bash
terraform init
```

4. Update terraform.tfvars with required values:
```hcl
subscription_id             = "your-subscription-id"
admin_group_object_ids     = ["aad-admin-group-id"]
private_dns_zone_id        = "dns-zone-resource-id"
log_analytics_workspace_id = "workspace-resource-id"
```

5. Deploy the infrastructure:
```bash
terraform plan -out=tfplan
terraform apply tfplan
```

## State Management

- State is stored in Azure Storage
- Implements state locking
- Enables team collaboration
- Supports state versioning

## Security Features

- Private cluster deployment
- Azure AD RBAC integration
- Network security groups with strict rules
- Private endpoints for Azure services
- Microsoft Defender for Containers enabled
- Workload Identity support
- OIDC issuer configuration

## Best Practices Implemented

- Consistent resource naming
- Proper tagging strategy
- Module versioning
- Provider version constraints
- Resource grouping by purpose
- Network segregation
- Automated scaling configurations
- Proper access controls

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.