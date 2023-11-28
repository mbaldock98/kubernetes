resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group
  address_space       = [var.address_space]
}

resource "azurerm_private_dns_zone" "dns-zone" {
  for_each            = toset(var.dns_zones)
  name                = each.value
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns-vnet-link" {
  for_each              = toset(var.dns_zones)
  name                  = "${var.vnet_name}_${replace(each.value, ".", "-")}_link"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.dns-zone[each.value].name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}
