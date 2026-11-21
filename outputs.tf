// Required for Route tabel
output "firewall_private_ip" {
  value = azurerm_firewall.hub_fw.ip_configuration[0].private_ip_address
}