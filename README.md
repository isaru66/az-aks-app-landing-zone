# Azure Infrastructure with Terraform

This repository contains Terraform configurations for deploying a production-grade Azure infrastructure with AKS and supporting resources.

## Prerequisites

- Terraform >= 1.0.0
- Azure CLI >= 2.40.0
- Azure subscription with required permissions
- Azure AD admin group for AKS cluster administration

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