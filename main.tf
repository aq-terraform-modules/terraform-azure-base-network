locals {
  # Aggregate all nsgs into a list of map
  # ["nsg-subnet-public" = "id", "nsg-subnet-private" = "id"]
  azurerm_nsgs = {
    for index, nsg in azurerm_network_security_group.nsg_defined :
      nsg.name => nsg.id
  }
}

resource "azurerm_resource_group" "vnet_rg" {
  location = var.location
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "vnet" {
  name = var.virtual_network_name
  resource_group_name = azurerm_resource_group.vnet_rg.name
  location = var.location
  address_space = var.address_space
}

resource "azurerm_subnet" "subnet_public" {
  name = var.subnet_public["name"]
  resource_group_name = azurerm_resource_group.vnet_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [var.subnet_public["address_prefix"]]
  service_endpoints = lookup(var.subnet_public, "service_endpoints", null)
  enforce_private_link_endpoint_network_policies = lookup(var.subnet_public, "enforce_private_link_endpoint_network_policies", null)
  enforce_private_link_service_network_policies = lookup(var.subnet_public, "enforce_private_link_service_network_policies", null)
}

resource "azurerm_subnet" "subnet_private" {
  name = var.subnet_private["name"]
  resource_group_name = azurerm_resource_group.vnet_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [var.subnet_private["address_prefix"]]
  service_endpoints = lookup(var.subnet_private, "service_endpoints", null)
  enforce_private_link_endpoint_network_policies = lookup(var.subnet_private, "enforce_private_link_endpoint_network_policies", null)
  enforce_private_link_service_network_policies = lookup(var.subnet_private, "enforce_private_link_service_network_policies", null)
}

resource "azurerm_network_security_group" "nsg_defined" {
  for_each = var.nsgs
  name = "nsg-${each.key}"
  location = var.location
  resource_group_name = azurerm_resource_group.vnet_rg.name

  
  dynamic "security_rule" {
    for_each = each.value
    
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

resource "azurerm_subnet_network_security_group_association" "subnet_public_associate" {
  subnet_id = azurerm_subnet.subnet_public.id
  network_security_group_id = lookup(local.azurerm_nsgs, "nsg-${azurerm_subnet.subnet_public.name}", azurerm_network_security_group.nsg_default.id)
}

resource "azurerm_subnet_network_security_group_association" "subnet_private_associate" {
  subnet_id = azurerm_subnet.subnet_private.id
  network_security_group_id = lookup(local.azurerm_nsgs, "nsg-${azurerm_subnet.subnet_private.name}", azurerm_network_security_group.nsg_default.id)
}