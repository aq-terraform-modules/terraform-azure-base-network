variable "name_prefix" {
  description = "Name prefix for all resources"
}

variable "location" {
  description = "Location of all resources"
}

variable "address_space" {
  type = list(string)
  description = "The address space that is used by the virtual network"
  default = ["10.0.0.0/16"]
}

variable "subnet_public" {
  description = "Public subnet"
  type = any
  default = {
    name = "subnet-public"
    address_prefix = "10.0.10.0/24"
    service_endpoints = []
    enforce_private_link_endpoint_network_policies = false
    enforce_private_link_service_network_policies = false
  }
}

variable "subnet_private" {
  description = "Public subnet"
  type = any
  default = {
    name = "subnet-private"
    address_prefix = "10.0.20.0/24"
    service_endpoints = []
    enforce_private_link_endpoint_network_policies = false
    enforce_private_link_service_network_policies = false
  }
}

variable "nsgs" {
  type = any
  description = "A map of nsg name to nsg rule"
  default = {
    "subnet-public" = [
      {
        name = "HTTP"
        priority = "100"
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "80"
        source_address_prefix = "*"
        destination_address_prefix  = "*"
      },
      {
        name = "HTTPS"
        priority = "110"
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "443"
        source_address_prefix = "*"
        destination_address_prefix  = "*"
      },
      {
        name = "SSH"
        priority = "120"
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefix = "*"
        destination_address_prefix  = "*"
      },
      {
        name = "RDP"
        priority = "130"
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "3389"
        source_address_prefix = "*"
        destination_address_prefix  = "*"
      }
    ]
  }
}