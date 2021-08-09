resource "azurerm_resource_group" "vnet_rg" {
  location = var.location
  name = "${var.name_prefix}-WLRG"
}

resource "azurerm_virtual_network" "vnet" {
  name = "${var.name_prefix}-VNET"
  resource_group_name = azurerm_resource_group.vnet_rg.name
  location = var.location
  address_space = var.address_space
}

resource "azurerm_subnet" "subnets" {
  count = length(var.subnets)
  name = var.subnet_names[count.index]["name"]
  resource_group_name = azurerm_resource_group.vnet_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [var.subnet_names[count.index]["address_prefix"]]
  service_endpoints = lookup(var.subnet_names[count.index], "service_endpoints", null)
  enforce_private_link_endpoint_network_policies = lookup(var.subnet_names[count.index], "enforce_private_link_endpoint_network_policies", false)
  enforce_private_link_service_network_policies = lookup(var.subnet_names[count.index], "enforce_private_link_service_network_policies", false)
}

resource "azurerm_network_security_group" "nsg_defined" {
  count = length(var.nsg_names)
  name = var.nsg_names[count.index]
  location = var.location
  resource_group_name = azurerm_resource_group.vnet_rg.name
  # security_rule = lookup(var.security_rules, var.nsg_names[count.index], null)

  
  dynamic "security_rule" {
    for_each = lookup(var.nsg_rules, var.nsg_names[count.index], [])
    
    content {
      name = security_rule.value["name"]
      priority = security_rule.value["priority"]
      direction = security_rule.value["direction"]
      access = security_rule.value["access"]
      protocol = security_rule.value["protocol"]
      source_port_range = security_rule.value["source_port_range"]
      destination_port_range = security_rule.value["destination_port_range"]
      source_address_prefix = security_rule.value["source_address_prefix"]
      destination_address_prefix = security_rule.value["destination_address_prefix"]
    }
  }
}

resource "azurerm_network_security_group" "nsg_default" {
  name = "nsg-subnet-default"
  location = var.location
  resource_group_name = azurerm_resource_group.vnet_rg.name
}

locals {
  azurerm_nsgs = {
    for index, nsg in azurerm_network_security_group.nsg_defined :
      nsg.name => nsg.id
  }
}

# nsg-subnet-public ==> id
# nsg-subnet-private ==> id

resource "azurerm_subnet_network_security_group_association" "nsg-associate" {
  for_each = azurerm_subnet.subnets
  subnet_id = each.id
  network_security_group_id = lookup(local.azurerm_nsgs, "nsg-${each.name}", azurerm_network_security_group.nsg-default.id)
}