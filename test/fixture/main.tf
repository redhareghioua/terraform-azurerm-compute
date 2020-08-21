provider "azurerm" {
  features {}
}

resource "random_id" "ip_dns" {
  byte_length = 4
}

data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "host${random_id.ip_dns.hex}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "host${random_id.ip_dns.hex}-vn"
  location            = var.location_alt
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "subnet1" {
  name                 = "host${random_id.ip_dns.hex}-sn-1"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "host${random_id.ip_dns.hex}-sn-2"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "subnet3" {
  name                 = "host${random_id.ip_dns.hex}-sn-3"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.test.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_key_vault" "test" {
  name                        = "kv-${random_id.ip_dns.hex}"
  location                    = azurerm_resource_group.test.location
  resource_group_name         = azurerm_resource_group.test.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption = true
  soft_delete_enabled         = true
  purge_protection_enabled    = true
  sku_name                    = "standard"

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}

module "host_instance_netscaler" {
  source = "../../"
  ## common section ==============================
  resource_group_name = azurerm_resource_group.test.name

  disk_encryption_key_vault_id = azurerm_key_vault.test.id
  ad_group_deploiement_id      = "54e6c69d-8260-4758-8517-56ce94b85885"
  ## vm section ==================================
  vm_hostname = "netscaler-service"
  vm_config   = var.vm_config

  source_image_reference = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  custom_data      = ""
  boot_diagnostics = false

  ## nic section =================================
  nics = {
    default = {
      name      = "default"
      subnet_id = azurerm_subnet.subnet1.id
      asg       = []
      rules = {
        inbound = [
          {
            name             = "ssh"
            protocol         = "TCP"
            ports            = ["22"]
            address_prefixes = ["10.0.0.1"]
          }
        ]
        outbound = [
          {
            name             = "ssh"
            protocol         = "TCP"
            ports            = ["22"]
            address_prefixes = ["10.0.0.1"]
          }
        ]
      }
    }
  }

  #tags = local.tags
}



module "host_instance_2" {
  source = "../../"

  resource_group_name          = azurerm_resource_group.test.name
  disk_encryption_key_vault_id = azurerm_key_vault.test.id
  ad_group_deploiement_id      = "54e6c69d-8260-4758-8517-56ce94b85885"
  vm_hostname                  = "test-service"
  vm_config                    = var.vm_config
  is_windows_image             = true

  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  nics = {
    default = {
      name      = "default"
      subnet_id = azurerm_subnet.subnet2.id
      asg       = []
      rules = {
        inbound  = []
        outbound = []
      }
    }
  }

  #tags = local.tags
}