output "subnet_public_id" {
  description = "ID of public subnet"
  value       = azurerm_subnet.subnet_public.id
}

output "subnet_private_id" {
  description = "ID of private subnet"
  value       = azurerm_subnet.subnet_private.id
}