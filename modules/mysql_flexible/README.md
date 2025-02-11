# Azure MySQL Flexible Server Terraform Module

This module deploys an Azure MySQL Flexible Server with comprehensive configurations for high availability, security, monitoring, and networking.

## Features

- Configurable server specifications (SKU, storage, version)
- High Availability configuration with standby zone support
- Private networking with subnet delegation
- Automated backups with configurable retention
- Comprehensive monitoring with Azure Monitor integration
- Enhanced security with TLS 1.2 enforcement
- Maintenance window configuration
- VNet integration with custom firewall rules

## Usage

```hcl
module "mysql_flexible" {
  source = "./modules/mysql_flexible"

  server_name           = "my-mysql-server"
  resource_group_name   = "my-resource-group"
  location             = "eastus2"
  administrator_login   = "mysqladmin"
  administrator_password = "your-secure-password"
  
  # Network configuration
  subnet_id            = "/subscriptions/.../subnets/mysql-subnet"
  private_dns_zone_id  = "/subscriptions/.../privateDnsZones/mysql.database.azure.com"
  subnet_cidr          = "10.0.1.0/24"
  
  # Server specifications
  sku_name             = "GP_Standard_D2ds_v4"
  mysql_version        = "8.0.21"
  zone                 = "1"
  
  # Storage configuration
  storage_iops         = 360
  storage_size_gb      = 20
  
  # High Availability
  high_availability_mode = "ZoneRedundant"
  standby_availability_zone = "2"
  
  # Backup configuration
  backup_retention_days = 7
  
  # Maintenance window
  maintenance_window = {
    day_of_week  = 0
    start_hour   = 3
    start_minute = 0
  }
  
  # Monitoring
  log_analytics_workspace_id = "/subscriptions/.../workspaces/my-workspace"
  
  tags = {
    Environment = "Production"
    Project     = "MyProject"
  }
}
```

## Required Variables

| Name | Description | Type | Required |
|------|-------------|------|----------|
| server_name | The name of the MySQL Flexible Server | string | yes |
| resource_group_name | The name of the resource group | string | yes |
| location | Azure region where the server will be deployed | string | yes |
| administrator_login | Administrator username | string | yes |
| administrator_password | Administrator password | string | yes |
| subnet_id | ID of the subnet for server deployment | string | yes |
| private_dns_zone_id | ID of the private DNS zone | string | yes |
| subnet_cidr | CIDR range of the subnet | string | yes |
| log_analytics_workspace_id | ID of the Log Analytics workspace | string | yes |

## Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| mysql_version | MySQL version | string | "8.0.21" |
| sku_name | SKU name for the server | string | "GP_Standard_D2ds_v4" |
| storage_iops | Storage IOPS | number | 360 |
| storage_size_gb | Storage size in GB | number | 20 |
| backup_retention_days | Backup retention period in days | number | 7 |
| zone | Availability zone number | string | "1" |
| high_availability_mode | HA mode (Disabled/ZoneRedundant) | string | "Disabled" |
| tags | Resource tags | map(string) | {} |

## Outputs

| Name | Description |
|------|-------------|
| server_id | The ID of the MySQL Flexible Server |
| server_fqdn | The FQDN of the MySQL Flexible Server |
| server_name | The name of the MySQL Flexible Server |

## Security Features

- TLS 1.2 enforcement
- Secure transport requirement
- Private network integration
- Automated diagnostic logging
- Network isolation through firewall rules

## Notes

- The server is deployed in a private network configuration
- High Availability requires GP or Memory Optimized SKU
- Maintenance window is configurable to minimize impact
- All connections require SSL/TLS
- Comprehensive logging is enabled by default

## Subnet Delegation Example

```hcl
resource "azurerm_subnet" "mysql" {
  name                 = "mysql-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = ["10.0.5.0/24"]
  
  delegation {
    name = "mysql-delegation"
    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}