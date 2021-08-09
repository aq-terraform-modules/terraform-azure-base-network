locals {
  # Aggregate all nsgs into a list of map
  # ["nsg-subnet-public" = "id", "nsg-subnet-private" = "id"]
  azurerm_nsgs = {
    for index, nsg in azurerm_network_security_group.nsg_defined :
      nsg.name => nsg.id
  }

  # Aggregate all subnets into a list of map
  # ["subnet-public" = "id", "subnet-private" = "id", "subnet-database" = "id"]
  azurerm_subnets = {
    for index, subnet in azurerm_subnet.subnets :
      subnet.name => subnet.id
  }
}

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
  name = var.subnets[count.index]["name"]
  resource_group_name = azurerm_resource_group.vnet_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [var.subnets[count.index]["address_prefix"]]
  service_endpoints = lookup(var.subnets[count.index], "service_endpoints", null)
  enforce_private_link_endpoint_network_policies = lookup(var.subnets[count.index], "enforce_private_link_endpoint_network_policies", null)
  enforce_private_link_service_network_policies = lookup(var.subnets[count.index], "enforce_private_link_service_network_policies", null)
}

resource "azurerm_network_security_group" "nsg_defined" {
  count = length(var.nsg_names)
  name = var.nsg_names[count.index]
  location = var.location
  resource_group_name = azurerm_resource_group.vnet_rg.name
  # security_rule = lookup(var.security_rules, var.nsg_names[count.index], null)

  
  dynamic "security_rule" {
    for_each = lookup(var.nsg_rules, var.nsg_names[count.index], [null])
    
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

# Every subnet need a nsg
# If the nsg-<subnet-name> is available, it will associate the nsg to the subnet
# If the nsg-<subnet-name> is not exist, it will associate the default nsg to the subnet
resource "azurerm_subnet_network_security_group_association" "nsg-associate" {
  for_each = local.azurerm_subnets
  subnet_id = each.value
  network_security_group_id = lookup(local.azurerm_nsgs, "nsg-${each.key}", azurerm_network_security_group.nsg_default.id)
}