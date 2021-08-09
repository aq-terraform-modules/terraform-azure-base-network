resource "azurerm_resource_group" "vnet-rg" {
  location = var.location
  name = "${var.name_prefix}-WLRG"
}

resource "azurerm_virtual_network" "vnet" {
  name = "${var.name_prefix}-VNET"
  resource_group_name = azurerm_resource_group.vnet-rg.name
  location = var.location
  address_space = var.address_space
}

resource "azurerm_subnet" "subnet" {
  count = length(var.subnet_names)
  name = var.subnet_names[count.index]
  resource_group_name = azurerm_resource_group.vnet-rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [var.subnet_prefixes[count.index]]
  service_endpoints = lookup(var.subnet_service_endpoints, var.subnet_names[count.index], null)
  enforce_private_link_endpoint_network_policies = lookup(var.subnet_enforce_private_link_endpoint_network_policies, var.subnet_names[count.index], false)
  enforce_private_link_service_network_policies = lookup(var.subnet_enforce_private_link_service_network_policies, var.subnet_names[count.index], false)
}

resource "azurerm_network_security_group" "nsg-defined" {
  count = length(var.nsg_names)
  name = var.nsg_names[count.index]
  location = var.location
  resource_group_name = azurerm_resource_group.vnet-rg.name
  # security_rule = lookup(var.security_rules, var.nsg_names[count.index], null)
}

resource "azurerm_network_security_group" "nsg-default" {
  count = length(var.subnet_names) > length(var.nsg_names) ? 1 : 0
  name = "nsg-subnet-default"
  location = var.location
  resource_group_name = azurerm_resource_group.vnet-rg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg-associate" {
  count = length(var.subnet_names)
  subnet_id = azurerm_subnet.subnet[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg-defined[count.index] != null ? azurerm_network_security_group.nsg-defined[count.index].id : azurerm_network_security_group.nsg-default.id
}