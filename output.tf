output "public_subnet_ids" {
  description = "The ids of subnets created inside the new vNet"
  value       = azurerm_subnet.subnet-public.*.id
}

output "public_subnet_names" {
  description = "The names of subnets created inside the new vNet"
  value       = azurerm_subnet.subnet-public.*.name
}

output "private_subnet_ids" {
  description = "The ids of subnets created inside the new vNet"
  value       = azurerm_subnet.subnet-private.*.id
}

output "private_subnet_names" {
  description = "The names of subnets created inside the new vNet"
  value       = azurerm_subnet.subnet-private.*.name
}