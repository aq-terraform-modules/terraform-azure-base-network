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

variable "subnet_names" {
  type = list(string)
  description = "A list of subnet name inside the VNET"
  default = ["subnet-public", "subnet-private"]
}

variable "subnet_prefixes" {
  type = list(string)
  description = "A list of subnet inside the VNET"
  default = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "subnet_service_endpoints" {
  description = "A map of subnet name to service endpoints to add to the subnet."
  type        = map(any)
  default     = {}
}

variable "subnet_enforce_private_link_endpoint_network_policies" {
  description = "A map of subnet name to enable/disable private link endpoint network policies on the subnet."
  type        = map(bool)
  default     = {}
}

variable "subnet_enforce_private_link_service_network_policies" {
  description = "A map of subnet name to enable/disable private link service network policies on the subnet."
  type        = map(bool)
  default     = {}
}

variable "nsg_names" {
  type = list(string)
  description = "A list of NSG name"
  default = ["nsg-subnet-public", "nsg-subnet-private"]
}

variable "nsg_rules" {
  type = map(list(any))
  description = "A map of nsg name to nsg rule"
  default = {
    "nsg-public" : [
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