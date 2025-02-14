output "vm_public_ip" {
  description = "Public IP of the virtual machine"
  value       = azurerm_public_ip.vm_public_ip.ip_address
}

output "container_app_url" {
  description = "The URL of the deployed Azure Container App"
  value       = azurerm_container_app.container_app.latest_revision_fqdn
}
