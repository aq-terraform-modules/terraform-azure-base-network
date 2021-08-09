output "subnet_names" {
  description = "Name of all subnets"
  value = azurerm_subnet.subnets.*.name
}

output "subnet_ids" {
  description = "ID of all subnets"
  value = azurerm_subnet.subnets.*.id
}