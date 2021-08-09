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

resource "azurerm_subnet" "subnet-public" {
  count = length(var.subnet_private)
  name = var.subnet_public[count.index]["name"]
  resource_group_name = azurerm_resource_group.vnet-rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [var.subnet_public[count.index]["address_prefix"]]
  service_endpoints = length(var.subnet_public[count.index]["service_endpoints"]) > 0 ? var.subnet_public[count.index]["service_endpoints"] : null
  enforce_private_link_endpoint_network_policies = length(var.subnet_public[count.index]["enforce_private_link_endpoint_network_policies"]) > 0 ? var.subnet_public[count.index]["enforce_private_link_endpoint_network_policies"] : null
  enforce_private_link_service_network_policies = length(var.subnet_public[count.index]["enforce_private_link_service_network_policies"]) > 0 ? var.subnet_public[count.index]["enforce_private_link_service_network_policies"] : null
}

resource "azurerm_subnet" "subnet-private" {
  count = length(var.subnet_private)
  name = var.subnet_private[count.index]["name"]
  resource_group_name = azurerm_resource_group.vnet-rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [var.subnet_private[count.index]["address_prefix"]]
  service_endpoints = length(var.subnet_private[count.index]["service_endpoints"]) > 0 ? var.subnet_private[count.index]["service_endpoints"] : null
  enforce_private_link_endpoint_network_policies = length(var.subnet_private[count.index]["enforce_private_link_endpoint_network_policies"]) > 0 ? var.subnet_private[count.index]["enforce_private_link_endpoint_network_policies"] : null
  enforce_private_link_service_network_policies = length(var.subnet_private[count.index]["enforce_private_link_service_network_policies"]) > 0 ? var.subnet_private[count.index]["enforce_private_link_service_network_policies"] : null
}

resource "azurerm_network_security_group" "nsg-defined" {
  count = length(var.nsg_names)
  name = var.nsg_names[count.index]
  location = var.location
  resource_group_name = azurerm_resource_group.vnet-rg.name
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

resource "azurerm_network_security_group" "nsg-default" {
  name = "nsg-subnet-default"
  location = var.location
  resource_group_name = azurerm_resource_group.vnet-rg.name
}

/* resource "azurerm_subnet_network_security_group_association" "nsg-associate" {
  count = length(var.subnet_names)
  subnet_id = azurerm_subnet.subnet[count.index].id
  network_security_group_id = count.index <= (length(azurerm_network_security_group.nsg-defined)-1) ? azurerm_network_security_group.nsg-defined[count.index].id : azurerm_network_security_group.nsg-default.id
} */
