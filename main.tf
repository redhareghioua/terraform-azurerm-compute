provider "azurerm" {
  version = "2.16"
  features {}
}

module "os" {
  source       = "./os"
  vm_os_simple = var.vm_os_simple
}

data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {
}

data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

data "azurerm_resource_group" "vm" {
  name = var.resource_group_name
}

resource "random_id" "vm-sa" {
  keepers = {
    vm_hostname = var.vm_hostname
  }

  byte_length = 6
}

resource "azurerm_availability_set" "vm" {
  name                         = "${var.vm_hostname}-avset"
  resource_group_name          = data.azurerm_resource_group.vm.name
  location                     = coalesce(var.location, data.azurerm_resource_group.vm.location)
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
  tags                         = var.tags
}

resource "azurerm_public_ip" "vm" {
  count               = var.nb_public_ip
  name                = "${var.vm_hostname}-pip-${count.index}"
  resource_group_name = data.azurerm_resource_group.vm.name
  location            = coalesce(var.location, data.azurerm_resource_group.vm.location)
  allocation_method   = var.allocation_method
  domain_name_label   = element(var.public_ip_dns, count.index)
  tags                = var.tags
}



