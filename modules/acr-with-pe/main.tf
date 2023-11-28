resource "azurerm_container_registry" "acr" {
  name                = "${replace(var.name_prefix, "-", "")}acr"
  resource_group_name = var.resource_group
  location            = var.location
  sku                 = "Premium"
  admin_enabled       = false
}

resource "azurerm_private_endpoint" "acr-pe" {
  name                = "${var.name_prefix}-pe"
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${azurerm_container_registry.acr.name}-pe-connection"
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names = ["registry"]
  }
}
