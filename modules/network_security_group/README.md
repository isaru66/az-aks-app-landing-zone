# Azure Network Security Group Module

This module deploys Network Security Groups (NSGs) with pre-configured security rules for enterprise environments.

## Features

### Security Rules
- Tiered security model
- Application-specific rules
- Service tag support
- Priority-based processing
- Deny by default
- Protocol restrictions

### Management
- Rule documentation
- ASG integration
- Flow logging
- Traffic analytics
- Rule auditing

### Monitoring
- Diagnostic settings
- Security insights
- Rule hit counting
- Threat detection
- Compliance reporting

## Usage

```hcl
module "nsg" {
  source = "./modules/network_security_group"

  name                = "aks-subnet-nsg"
  resource_group_name = module.resource_group.name
  location           = "eastus2"

  security_rules = [
    {
      name                       = "allow_tls"
      priority                   = 100
      direction                  = "Inbound"
      access                    = "Allow"
      protocol                  = "Tcp"
      source_port_range         = "*"
      destination_port_range    = "443"
      source_address_prefix     = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    },
    {
      name                       = "deny_all_inbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                    = "Deny"
      protocol                  = "*"
      source_port_range         = "*"
      destination_port_range    = "*"
      source_address_prefix     = "*"
      destination_address_prefix = "*"
    }
  ]

  tags = {
    Environment = "Production"
    Project     = "Core Infrastructure"
  }
}
```

## Required Resources
- Resource Group
- Log Analytics workspace for diagnostics
- Network Watcher for flow logs

## Variables

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| name | NSG name | string | yes | - |
| resource_group_name | Resource group name | string | yes | - |
| location | Azure region | string | yes | - |
| security_rules | List of security rules | list(map) | no | [] |
| flow_log_enabled | Enable NSG flow logs | bool | no | true |
| tags | Resource tags | map(string) | no | {} |

## Outputs

| Name | Description |
|------|-------------|
| nsg_id | The NSG resource ID |
| nsg_name | The name of the NSG |
| security_rules | List of security rules |

## Best Practices
1. Follow least privilege principle
2. Document all rules
3. Use service tags where possible
4. Enable flow logging
5. Regular rule review
6. Monitor denied traffic
7. Keep rules organized
8. Use meaningful priorities

## Related Modules
- `virtual_network` - For network configuration
- `subnet` - For subnet association
- `log_analytics` - For monitoring
- `bastion` - For secure access rules

## Notes
- Rules process in priority order
- Document all rule changes
- Regular security audits
- Monitor rule effectiveness
- Consider compliance requirements
- Plan rule capacity