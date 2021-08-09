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
  description = "Private subnet information"
  type        = list(any)
  default     = [
    {
      name = "subnet-public"
      address_prefix = "10.0.10.0/24"
    }
  ]
}

variable "subnet_private" {
  description = "Private subnet information"
  type        = list(any)
  default     = [
    {
      name = "subnet-private"
      cidr = "10.0.20.0/24"
    }
  ]
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
    "nsg-subnet-public" : [
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