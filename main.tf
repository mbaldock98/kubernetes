resource "azurerm_resource_group" "kube-rg" {
  name     = "kube-rg"
  location = "uksouth"
}

resource "azurerm_virtual_network" "kube-vnet" {
  name                = "kube-vnet"
  location            = azurerm_resource_group.kube-rg.location
  resource_group_name = azurerm_resource_group.kube-rg.name
  address_space       = ["10.1.0.0/16"]
}

module "kube-subnets" {
  for_each           = local.subnets
  source             = "./modules/subnet-and-nsg"
  name_prefix        = each.key
  location           = azurerm_resource_group.kube-rg.location
  resource_group     = azurerm_resource_group.kube-rg.name
  vnet_name          = azurerm_virtual_network.kube-vnet.name
  snet_address_space = each.value.address_space
}

module "kube-registry" {
  source         = "./modules/acr-with-pe"
  name_prefix    = "kube-registry"
  location       = azurerm_resource_group.kube-rg.location
  resource_group = azurerm_resource_group.kube-rg.name
  subnet_id      = module.kube-subnets["kube-registry"].subnet_id
}
