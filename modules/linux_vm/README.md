# Linux Virtual Machine Module

A Terraform module for deploying Azure Linux Virtual Machines with secure configurations and management features.

## Prerequisites and Setup

### 1. Required Role Assignments
```bash
# Check VM permissions
az role assignment list \
    --assignee $(az account show --query user.name -o tsv) \
    --query "[?contains(roleDefinitionName, 'Virtual Machine')].roleDefinitionName" \
    -o tsv

# Assign Virtual Machine Contributor role if needed
az role assignment create \
    --assignee $(az account show --query user.name -o tsv) \
    --role "Virtual Machine Contributor" \
    --scope "/subscriptions/$(az account show --query id -o tsv)"
```

### 2. SSH Key Generation
```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_vm

# Store public key in Key Vault (recommended)
az keyvault secret set \
    --vault-name "your-keyvault" \
    --name "vm-ssh-pub-key" \
    --file "~/.ssh/azure_vm.pub"
```

## Features
- Managed disk support
- Backup integration
- OS patching management
- Identity management
- Custom data scripts
- Boot diagnostics
- Azure Monitor integration
- Network security
- Disk encryption
- Tag management
- Auto-shutdown
- Maintenance configuration

## Usage

```hcl
module "linux_vm" {
  source = "./modules/linux_vm"

  # Basic Configuration
  name                = "vm-prod-app01"
  resource_group_name = module.resource_group.name
  location           = "eastus"
  
  # VM Size and Image
  size = "Standard_D2s_v3"
  source_image_reference = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  
  # Admin Configuration
  admin_username = var.vm_admin_username
  admin_ssh_key = {
    username   = var.vm_admin_username
    public_key = data.azurerm_key_vault_secret.ssh_public_key.value
  }
  
  # Network Configuration
  network_interface = {
    name      = "nic-vm-prod-app01"
    subnet_id = module.subnet["app"].id
    private_ip_address_allocation = "Dynamic"
  }
  
  # Identity Configuration
  identity_type = "SystemAssigned"
  
  # OS Disk Configuration
  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb        = 64
    disk_encryption_set_id = module.disk_encryption_set.id
  }
  
  # Data Disks
  data_disks = [
    {
      name                 = "data-disk-1"
      storage_account_type = "Premium_LRS"
      disk_size_gb        = 256
      lun                 = 0
      caching             = "ReadWrite"
    }
  ]
  
  # Backup Configuration
  backup = {
    recovery_vault_name = module.recovery_services.name
    backup_policy_id    = module.recovery_services.vm_backup_policy_id
  }
  
  # Monitoring Configuration
  monitoring = {
    log_analytics_workspace_id = module.log_analytics.id
    storage_account_id         = module.storage.id
  }
  
  # Auto-shutdown Configuration
  auto_shutdown = {
    enabled = true
    time    = "2200"
    timezone = "UTC"
  }
  
  # Custom Data Script
  custom_data = base64encode(file("${path.module}/scripts/setup.sh"))
  
  # Maintenance Configuration
  maintenance = {
    auto_updates_enabled = true
    patch_mode          = "AutomaticByPlatform"
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Backup      = "Daily"
    Patch       = "Automatic"
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
| name | VM name | string | yes | - |
| resource_group_name | Resource group name | string | yes | - |
| location | Azure region | string | yes | - |
| size | VM size | string | yes | - |
| admin_username | Admin username | string | yes | - |
| admin_ssh_key | SSH key configuration | object | yes | - |
| network_interface | NIC configuration | object | yes | - |
| source_image_reference | OS image configuration | object | yes | - |
| os_disk | OS disk configuration | object | no | {} |
| data_disks | Data disk configurations | list(object) | no | [] |
| identity_type | Identity type | string | no | "SystemAssigned" |
| backup | Backup configuration | object | no | null |
| monitoring | Monitoring configuration | object | no | null |
| auto_shutdown | Auto-shutdown configuration | object | no | null |
| custom_data | Custom data script | string | no | null |
| maintenance | Maintenance configuration | object | no | null |
| tags | Resource tags | map(string) | no | {} |

## Outputs

| Name | Description |
|------|-------------|
| vm_id | The VM resource ID |
| vm_name | The name of the VM |
| private_ip_address | The private IP address |
| identity | The VM's managed identity |
| public_ip_address | The public IP (if configured) |

## Best Practices

### Security
- Use managed disks
- Enable disk encryption
- Implement backup
- Configure networking
- Use SSH keys
- Regular updates
- Monitor access
- Security baselines

### Performance
- Right-size VMs
- Premium storage
- Monitoring setup
- Load balancing
- Availability sets
- Scale sets
- Performance rules
- Resource optimization

### Management
- Automated patching
- Backup policies
- Monitoring alerts
- Cost tracking
- Tag strategy
- Access control
- Change management
- Documentation

### Networking
- NSG configuration
- Private endpoints
- Network isolation
- Traffic monitoring
- Bastion access
- Route tables
- DNS configuration
- Load balancing

### Cost Optimization
- Right-sizing
- Auto-shutdown
- Reserved instances
- Monitor usage
- Cost allocation
- Resource scheduling
- Budget alerts
- Usage optimization

### Maintenance
- Update management
- Patch scheduling
- Health monitoring
- Backup validation
- Recovery testing
- Configuration management
- Change tracking
- Compliance checks