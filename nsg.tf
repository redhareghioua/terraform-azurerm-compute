locals {
  priority_start = 100
}
# resource "azurerm_network_security_rule" "vm" {
#   count                       = var.remote_port != "" ? 1 : 0
#   name                        = "allow_remote_${coalesce(var.remote_port, module.os.calculated_remote_port)}_in_all"
#   resource_group_name         = data.azurerm_resource_group.vm.name
#   description                 = "Allow remote protocol in from all locations"
#   priority                    = 101
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = coalesce(var.remote_port, module.os.calculated_remote_port)
#   source_address_prefixes     = var.source_address_prefixes
#   destination_address_prefix  = "*"
#   network_security_group_name = azurerm_network_security_group.vm.name
# }

resource "azurerm_network_security_group" "main" {
  for_each = var.nics

  name                = "nsg-nic-${each.value["name"]}"
  location            = coalesce(var.location, data.azurerm_resource_group.vm.location)
  resource_group_name = data.azurerm_resource_group.resource_group.name

  security_rule {
    name                       = "deny-all-inbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny-all-outbound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # dynamic rules
  dynamic "security_rule" {
    iterator = security_rule
    for_each = each.value.rules.inbound
    content {
      name                       = "${each.value["name"]}_${security_rule.value.name}-inbound"
      priority                   = format(security_rule.key + local.priority_start)
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = security_rule.value.protocol
      source_address_prefixes    = security_rule.value.address_prefixes
      source_port_range          = "*"
      destination_address_prefix = azurerm_network_interface.main[each.key].private_ip_address
      destination_port_ranges    = security_rule.value.ports
    }
  }

  dynamic "security_rule" {
    iterator = security_rule
    for_each = each.value.rules.outbound
    content {
      name                         = "${each.value["name"]}_${security_rule.value.name}-outbound"
      priority                     = format(security_rule.key + local.priority_start)
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = security_rule.value.protocol
      source_address_prefix        = "*"
      source_port_range            = "*"
      destination_address_prefixes = security_rule.value.address_prefixes
      destination_port_ranges      = security_rule.value.ports
    }
  }
  tags = var.tags
}

## end nsg generic ================================================================================

## asg association =========================================================================
resource "azurerm_network_interface_application_security_group_association" "generic_asg_association_default" {
  for_each = toset(var.nics["default"].asg)

  network_interface_id          = azurerm_network_interface.main["default"].id
  application_security_group_id = each.value
}

# resource "azurerm_network_interface_application_security_group_association" "generic_asg_association_mngt" {
#   for_each = toset(var.nics["mngt"].asg)

#   network_interface_id          = azurerm_network_interface.main["mngt"].id
#   application_security_group_id = each.value
# }
## end asg association =========================================================================
