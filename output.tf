output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "public_subnet_name" {
  description = "The name of the public subnet"
  value       = azurerm_subnet.public_subnet.name
}

output "private_subnet_name" {
  description = "The name of the private subnet"
  value       = azurerm_subnet.private_subnet.name
}

output "vm_public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}
