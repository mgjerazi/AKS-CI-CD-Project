output "public-ip" {
  value = azurerm_public_ip.main.*.ip_address
}

output "private-ip" {
  value = azurerm_network_interface.main.*.private_ip_address
}