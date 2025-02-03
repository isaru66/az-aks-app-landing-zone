# Private DNS Zone Module

A Terraform module for managing Azure Private DNS Zones with virtual network links and record sets.

## Features

- Private DNS zone creation and management
- Virtual network linking support
- DNS record set management
- Auto-registration configuration
- Zone redundancy support
- Tags management

## Usage

```hcl
module "private_dns_zone" {
  source = "./modules/private_dns_zone"

  name                = "internal.contoso.com"
  resource_group_name = module.resource_group.name
  
  virtual_network_links = [
    {
      name                 = "prod-vnet-link"
      virtual_network_id   = module.vnet.id
      registration_enabled = true
      tags = {
        Environment = "Production"
      }
    }
  ]

  a_records = [
    {
      name    = "api"
      ttl     = 300
      records = ["10.0.1.4"]
    }
  ]

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
| name | Name of the private DNS zone | string | yes | - |
| resource_group_name | Resource group name | string | yes | - |
| virtual_network_links | Virtual network link configurations | list(object) | no | [] |
| a_records | A record configurations | list(object) | no | [] |
| aaaa_records | AAAA record configurations | list(object) | no | [] |
| cname_records | CNAME record configurations | list(object) | no | [] |
| tags | Resource tags | map(string) | no | {} |

### Virtual Network Link Object

```hcl
object({
  name                 = string
  virtual_network_id   = string
  registration_enabled = bool
  tags                = map(string)
})
```

### DNS Record Object

```hcl
object({
  name    = string
  ttl     = number
  records = list(string)
})
```

## Outputs

| Name | Description |
|------|-------------|
| id | The Private DNS Zone ID |
| name | The name of the Private DNS Zone |
| number_of_record_sets | The number of record sets in the zone |

## Best Practices

### Naming Convention
- Use meaningful domain names
- Consider organizational structure
- Plan for future expansion
- Document naming scheme

### Virtual Network Links
- Enable auto-registration where appropriate
- Monitor link status
- Plan for cross-region links
- Consider hub-spoke architectures

### Record Management
- Use appropriate TTL values
- Document record purposes
- Regular record auditing
- Plan for DR scenarios

### Security
- Restrict zone access
- Monitor DNS queries
- Regular security reviews
- Document access controls