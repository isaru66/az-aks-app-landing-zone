output "vm_id" {
  description = "The ID of the Linux Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.id
}

output "vm_private_ip" {
  description = "The Private IP address of the Linux Virtual Machine"
  value       = azurerm_network_interface.vm_nic.private_ip_address
}

output "vm_name" {
  description = "The name of the Linux Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.name
}

output "network_interface_id" {
  description = "The ID of the Network Interface Card"
  value       = azurerm_network_interface.vm_nic.id
}

output "system_assigned_identity_principal_id" {
  description = "The Principal ID of the VM's system assigned identity"
  value       = azurerm_linux_virtual_machine.vm.identity[0].principal_id
}