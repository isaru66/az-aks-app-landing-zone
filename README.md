# Azure Infrastructure with Terraform

This repository contains Terraform configurations for deploying a production-grade Azure infrastructure with AKS and supporting resources.

## Prerequisites

- Terraform >= 4.17.0
- Azure CLI >= 2.40.0
- Azure subscription with required permissions
- Azure AD admin group for AKS cluster administration
- Git
- Text editor (VS Code recommended)

## Repository Structure

```
.
├── modules/
│   ├── aad_group/              # Azure AD Group management
│   ├── acr/                    # Azure Container Registry
│   ├── aks/                    # Azure Kubernetes Service
│   ├── bastion/               # Azure Bastion Host
│   ├── keyvault/              # Azure Key Vault
│   ├── log_analytics/         # Log Analytics workspace
│   ├── network_security_group/ # NSG rules and configurations
│   ├── private_dns_zone/      # Private DNS zone settings
│   ├── resource_group/        # Resource group management
│   ├── storage/               # Azure Storage Account
│   ├── subnet/                # Subnet configurations
│   └── virtual_network/       # VNet and networking setup
├── main.tf                    # Main infrastructure configuration
├── providers.tf               # Provider configuration
├── variables.tf               # Input variables
├── outputs.tf                # Output values
└── terraform.tfvars         # Variable values
```

## Initial Setup and Authentication

### 1. Clone the Repository
```bash
git clone <repository-url>
cd terraform-azure-project
```

### 2. Install Azure CLI
```bash
# For macOS using Homebrew
brew update && brew install azure-cli

# For Windows using PowerShell
winget install -e --id Microsoft.AzureCLI

# For Ubuntu/Debian
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### 3. Azure Authentication and Subscription Setup
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

### 4. Required Permissions and Credentials
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

### 5. Create Service Principal for Terraform (Optional but recommended)
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

### 6. Configure Azure Storage for Terraform State
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

## Environment Setup

1. Create a terraform.tfvars file:
```hcl
# General
environment         = "prod"
location            = "eastus2"
subscription_id     = "your-subscription-id"

# Networking
address_space       = ["10.0.0.0/16"]
subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24"]
subnet_names        = ["aks-subnet", "pe-subnet"]

# AKS
kubernetes_version  = "1.26.0"
admin_group_object_ids = ["your-admin-group-id"]
node_pool_vm_size  = "Standard_D4s_v3"
```

2. Set up backend configuration (backend.tfvars):
```hcl
storage_account_name = "tfstate[UNIQUE]"
container_name      = "tfstate"
key                 = "prod.terraform.tfstate"
resource_group_name = "terraform-state-rg"
```

## Deployment Steps

1. Initialize Terraform with backend configuration:
```bash
terraform init -backend-config=backend.tfvars
```

2. Validate the configuration:
```bash
terraform validate
```

3. Review the deployment plan:
```bash
terraform plan -out=tfplan
```

4. Apply the configuration:
```bash
terraform apply tfplan
```

## Module Configuration

Each module in this project can be configured independently. Here's a quick reference:

- **AKS**: Configure Kubernetes cluster settings
- **ACR**: Set up container registry with geo-replication
- **Key Vault**: Manage secrets and certificates
- **Storage**: Configure secure blob storage
- **Networking**: Set up virtual networks and security

Refer to each module's README for detailed configuration options.

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

## Maintenance and Updates

### Regular Updates
1. Update provider versions in providers.tf
2. Run `terraform init -upgrade`
3. Test in a non-production environment first
4. Apply updates during maintenance windows

### Backup and Recovery
- State file is versioned in Azure Storage
- Use terraform state backup before major changes
- Document all custom configurations

### Monitoring and Logging
- Enable diagnostic settings for all resources
- Configure Log Analytics workspace
- Set up alerts for critical metrics

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.