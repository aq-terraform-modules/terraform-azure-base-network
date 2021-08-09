output "subnet_ids" {
  description = "The ids of subnets created inside the new vNet"
  value       = azurerm_subnet.subnet.*.id
}

output "subnet_names" {
  description = "The names of subnets created inside the new vNet"
  value       = azurerm_subnet.subnet.*.name
}