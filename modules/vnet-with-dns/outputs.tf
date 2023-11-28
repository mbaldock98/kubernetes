output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "dns_zone_ids" {
  value = {for zone, attributes in azurerm_private_dns_zone.dns-zone : zone => attributes.id}
}