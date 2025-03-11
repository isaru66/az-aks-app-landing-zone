# Network Security Group (NSG) Module

A Terraform module for creating and managing Azure Network Security Groups with comprehensive security rules.

## Prerequisites and Setup

### 1. Required Role Assignments
```bash
# Check network security permissions
az role assignment list \
    --assignee $(az account show --query user.name -o tsv) \
    --query "[?contains(roleDefinitionName, 'Network')].roleDefinitionName" \
    -o tsv

# Assign Network Security Group Contributor role if needed
az role assignment create \
    --assignee $(az account show --query user.name -o tsv) \
    --role "Network Security Group Contributor" \
    --scope "/subscriptions/$(az account show --query id -o tsv)"
```

### 2. Flow Logs Setup (Optional)
```bash
# Enable Network Watcher if not enabled
az network watcher configure \
    --resource-group NetworkWatcherRG \
    --locations "eastus" \
    --enabled true

# Create storage account for flow logs
az storage account create \
    --name nsgflowlogs \
    --resource-group "your-rg" \
    --location "eastus" \
    --sku Standard_LRS
```

## Features
- Granular security rule management
- Service tag support
- Application security group integration
- Flow logging capabilities
- Subnet association
- Rule priority management
- Protocol-specific rules
- Port range configuration
- Source/destination filtering
- Custom rule descriptions

## Usage

```hcl
module "nsg" {
  source = "./modules/network_security_group"

  nsg_name            = "aks-subnet-nsg"
  resource_group_name = module.resource_group.name
  location           = "eastus"

  security_rules = [
    {
      name                         = "allow_aks_api"
      priority                     = 100
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "AzureCloud"
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow AKS API Server access"
    },
    {
      name                         = "allow_ssh_bastion"
      priority                     = 200
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "GatewayManager"
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow SSH from Azure Bastion"
    },
    {
      name                         = "allow_aks_loadbalancer"
      priority                     = 300
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = ["80", "443"]
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow access from Azure Load Balancer"
    },
    {
      name                         = "deny_all_inbound"
      priority                     = 4096
      direction                   = "Inbound"
      access                      = "Deny"
      protocol                    = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Deny all inbound traffic"
    }
  ]

  # Optional flow log configuration
  flow_log_retention_days = 7
  storage_account_id     = module.storage.id
  log_analytics_workspace_id = module.log_analytics.id

  # Optional subnet association
  subnet_id = module.subnet["aks"].id

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| azurerm | ~> 3.0 |

## Variables

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| nsg_name | NSG name | string | yes | - |
| resource_group_name | Resource group name | string | yes | - |
| location | Azure region | string | yes | - |
| security_rules | List of security rules | list(object) | no | [] |
| flow_log_retention_days | Flow log retention period | number | no | null |
| storage_account_id | Storage account for flow logs | string | no | null |
| log_analytics_workspace_id | Log Analytics workspace ID | string | no | null |
| subnet_id | Subnet ID for association | string | no | null |
| tags | Resource tags | map(string) | no | {} |

### Security Rule Object
```hcl
object({
  name                         = string
  priority                     = number
  direction                   = string
  access                      = string
  protocol                    = string
  source_port_range          = string
  destination_port_range     = string
  source_address_prefix      = string
  destination_address_prefix = string
  description                = string
})
```

## Outputs

| Name | Description |
|------|-------------|
| nsg_id | The NSG resource ID |
| nsg_name | The name of the NSG |
| security_rules | List of configured security rules |

## Best Practices

### Rule Priority
- Use priorities 100-499 for allow rules
- Use priorities 500-4096 for deny rules
- Leave gaps between rules for future insertions
- Document priority assignments
- Regular rule review
- Maintain rule order
- Consider rule dependencies
- Plan for emergency rules

### Service Tags
Utilize Azure service tags for better maintainability:
- AzureCloud
- VirtualNetwork
- Internet
- AzureLoadBalancer
- AzureTrafficManager
- GatewayManager
- AzureKubernetesService
- AzureContainerRegistry
- AzureKeyVault
- AzureBastion

### Security Considerations
- Implement least-privilege access
- Use specific port ranges instead of wildcards
- Document rule purposes using descriptions
- Regular audit of security rules
- Monitor rule effectiveness
- Plan for disaster recovery
- Test rule changes
- Maintain change log

### Common Configurations

#### AKS Cluster
```hcl
security_rules = [
  {
    name                = "allow_aks_api"
    priority            = 100
    destination_port_range = "443"
    source_address_prefix = "AzureCloud"
  }
]
```

#### Private Endpoints
```hcl
security_rules = [
  {
    name                = "allow_private_endpoint"
    priority            = 100
    destination_port_range = "443"
    source_address_prefix = "VirtualNetwork"
  }
]
```

#### Azure Bastion
```hcl
security_rules = [
  {
    name                = "allow_bastion"
    priority            = 100
    destination_port_ranges = ["22", "3389"]
    source_address_prefix = "GatewayManager"
  }
]
```

### Monitoring
- Enable flow logs
- Configure diagnostic settings
- Set up alerts
- Regular rule review
- Traffic analysis
- Security assessments
- Performance monitoring
- Compliance checking