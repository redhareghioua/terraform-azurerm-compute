resource "azurerm_network_interface" "main" {
  for_each = var.nics

  name                          = "nic-${var.vm_hostname}-${each.value["name"]}-${each.key}"
  location                      = coalesce(var.location, data.azurerm_resource_group.vm.location)
  resource_group_name           = data.azurerm_resource_group.resource_group.name
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "${each.value["name"]}-${var.vm_hostname}-ip-${each.key}"
    subnet_id                     = each.value["subnet_id"]
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id          = length(azurerm_public_ip.vm.*.id) > 0 ? element(concat(azurerm_public_ip.vm.*.id, list("")), each.key) : ""
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "nic_instance_nsg_association" {
  for_each = var.nics

  network_interface_id      = azurerm_network_interface.main[each.key].id
  network_security_group_id = azurerm_network_security_group.main[each.key].id
}
## end generic nic =======================================================================