# README.md

# Azure Infrastructure with Terraform

This repository contains Terraform configurations for deploying a production-grade Azure infrastructure with AKS.

## Prerequisites

- Terraform >= 1.0.0
- Azure CLI
- Azure subscription with required permissions
- Azure AD admin group for AKS cluster administration

## Infrastructure Components

- Private AKS cluster with:
  - Azure Linux (CBL-Mariner) as the node OS
  - Azure CNI networking
  - Azure network policy
  - System and workload node pools with autoscaling
  - Multi-zone deployment
  - Workload Identity and OIDC support
  - Microsoft Defender integration

### Autoscaling Configuration

The AKS cluster is configured with the following autoscaling features:
- Node pool autoscaling enabled for both system and user pools
- Optimized autoscaler profile with:
  - Balance similar node groups
  - 10-second scan interval for responsive scaling
  - Configurable scale down thresholds and delays
  - Protection for nodes with system pods and local storage
  - Graceful termination period of 10 minutes

## Getting Started

1. Initialize Azure backend:
```bash
az login
az group create --name terraform-state-rg --location eastus
terraform init
```

2. Update terraform.tfvars with your specific values:
- Update subscription_id
- Set appropriate admin_group_object_ids
- Configure private_dns_zone_id
- Set log_analytics_workspace_id

3. Deploy the infrastructure:
```bash
terraform plan -out=tfplan
terraform apply tfplan
```

## Module Structure

```
.
├── modules/
│   ├── aks/
│   ├── network_security_group/
│   ├── resource_group/
│   ├── subnet/
│   └── virtual_network/
├── backend.tf        # State management configuration
├── main.tf          # Main infrastructure configuration
├── providers.tf     # Provider configuration
├── variables.tf     # Input variables
├── outputs.tf       # Output values
└── terraform.tfvars # Variable values
```

## Security Features

- Private cluster with no public endpoints
- Azure AD integration for RBAC
- Network policies enabled
- Microsoft Defender for Containers
- Workload Identity support
- OIDC issuer enabled

## Node Pool Configuration

### System Node Pool
- Uses Azure Linux (CBL-Mariner) OS
- Dedicated to system workloads
- Autoscaling enabled with configurable min/max counts
- Critical addons only mode enabled

### User Node Pool
- Uses Azure Linux (CBL-Mariner) OS
- Dedicated to user workloads
- Autoscaling enabled with configurable min/max counts
- Optimized for production workloads

## Maintenance and Updates

- Automatic channel upgrade set to "stable"
- Configured maintenance window
- Node pool auto-scaling enabled
- Multi-zone deployment for high availability

## Best Practices

- State stored in Azure Storage with versioning
- Proper variable management
- Consistent naming conventions
- Provider version constraints (~> 3.0 for azurerm)
- Resource tagging
- Optimized autoscaling configuration
- Modern OS selection with Azure Linux

## License

This project is licensed under the MIT License. See the LICENSE file for details.