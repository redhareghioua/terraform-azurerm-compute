output "vm_ids" {
  description = "Virtual machine ids created."
  value       = concat(azurerm_windows_virtual_machine.windows_instance.*.id, azurerm_linux_virtual_machine.linux_instance.*.id)
}

output "principal_ids" {
  description = "Virtual machine principal_ids created."
  value       = var.is_windows_image ? azurerm_windows_virtual_machine.windows_instance[0].identity.0.principal_id : azurerm_linux_virtual_machine.linux_instance[0].identity.0.principal_id
}

output "disk_encryption_set_id" {
  value = azurerm_disk_encryption_set.main.id
}

output "public_ip_id" {
  description = "id of the public ip address provisoned."
  value       = azurerm_public_ip.vm.*.id
}

output "public_ip_address" {
  description = "The actual ip address allocated for the resource."
  value       = azurerm_public_ip.vm.*.ip_address
}

output "public_ip_dns_name" {
  description = "fqdn to connect to the first vm provisioned."
  value       = azurerm_public_ip.vm.*.fqdn
}

output "availability_set_id" {
  description = "id of the availability set where the vms are provisioned."
  value       = azurerm_availability_set.vm.id
}


# output "network_interface_ids" {
#   description = "ids of the vm nics provisoned."
#   value       = azurerm_network_interface.main.*.id
# }

# output "network_interface_private_ip" {
#   description = "private ip addresses of the vm nics"
#   value       = azurerm_network_interface.main.*.private_ip_address
# }

# output "network_security_group_id" {
#   description = "id of the security group provisioned"
#   value       = azurerm_network_security_group.vm.id
# }

# output "network_security_group_name" {
#   description = "name of the security group provisioned"
#   value       = azurerm_network_security_group.vm.name
# }
# output "vm_zones" {
#   description = "map with key `Virtual Machine Id`, value `list of the Availability Zone` which the Virtual Machine should be allocated in."
#   value       = zipmap(concat(azurerm_windows_virtual_machine.windows_instance.*.id, azurerm_linux_virtual_machine.linux_instance.*.id), concat(azurerm_linux_virtual_machine.linux_instance.*.zones, azurerm_windows_virtual_machine.windows_instance.*.zones))
# }
