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

variable "nst_rules" {
  type = map(any)
  description = "A map of nsg name to nsg rule"
  default = {
    "nsg-public" : [

    ],
    "nsg-private" : [

    ]
  }
}