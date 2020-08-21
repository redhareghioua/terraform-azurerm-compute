## azurerm_windows_virtual_machine =================================================================
resource "azurerm_windows_virtual_machine" "windows_instance" {
  count = var.is_windows_image ? var.nb_instances : 0

  name                  = "${var.vm_hostname}-vmWindows-${count.index}"
  location              = coalesce(var.location, data.azurerm_resource_group.vm.location)
  resource_group_name   = var.resource_group_name
  size                  = var.vm_config.vm_size
  network_interface_ids = [element([for value in azurerm_network_interface.main : value.id], count.index)]
  custom_data           = var.custom_data == "" ? base64encode("echo deploying...") : base64encode(var.custom_data)
  computer_name         = substr(var.vm_hostname, 0, 14)
  admin_username        = var.vm_config.admin_username
  admin_password        = var.vm_config.admin_password

  dynamic plan {
    for_each = var.plan.name != "" ? [1] : []
    content {
      name      = var.plan.name
      publisher = var.plan.publisher
      product   = var.plan.product
    }
  }

  dynamic "source_image_reference" {
    for_each = var.source_image_reference.publisher != "" ? [1] : []

    content {
      publisher = var.source_image_reference.publisher
      offer     = var.source_image_reference.offer
      sku       = var.source_image_reference.sku
      version   = var.source_image_reference.version
    }
  }

  source_image_id = var.source_image_reference.publisher != "" ? null : var.source_image_id

  os_disk {
    name                   = "${var.vm_hostname}-osdisk-${count.index}"
    caching                = "ReadWrite"
    storage_account_type   = var.storage_account_type
    disk_encryption_set_id = azurerm_disk_encryption_set.main.id
  }

  dynamic boot_diagnostics {
    for_each = var.boot_diagnostics ? [1] : []
    content {
      storage_account_uri = var.boot_diagnostics_uri
    }
  }

  lifecycle {
    ignore_changes = [size]
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# resource "azurerm_managed_disk" "main_win" {
#   count = var.is_windows_image  ? var.nb_instances : 0

#   name                 = "${var.vm_hostname}-disk1"
#   location              = coalesce(var.location, data.azurerm_resource_group.vm.location)
#   resource_group_name   = var.resource_group_name
#   storage_account_type = "Standard_LRS"
#   create_option        = "Empty"
#   disk_size_gb         = 10
# }

# resource "azurerm_virtual_machine_data_disk_attachment" "main_win" {
#   count = var.is_windows_image  ? var.nb_instances : 0

#   managed_disk_id    = azurerm_managed_disk.main_win.id
#   virtual_machine_id =  azurerm_windows_virtual_machine.windows_instance.*.id
#   lun                = "10"
#   caching            = "ReadWrite"
# }