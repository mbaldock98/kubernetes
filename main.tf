resource "azurerm_resource_group" "kube-rg" {
  name     = "kube-rg"
  location = "uksouth"
}

module "kube-vnet" {
  source         = "./modules/vnet-with-dns"
  vnet_name      = "kube-vnet"
  resource_group = azurerm_resource_group.kube-rg.name
  location       = azurerm_resource_group.kube-rg.location
  address_space  = "10.1.0.0/16"
  dns_zones      = ["azurecr.io"]
}

module "kube-subnets" {
  for_each           = local.subnets
  source             = "./modules/subnet-and-nsg"
  name_prefix        = each.key
  location           = azurerm_resource_group.kube-rg.location
  resource_group     = azurerm_resource_group.kube-rg.name
  vnet_name          = module.kube-vnet.vnet_name
  snet_address_space = each.value.address_space
}

module "kube-registry" {
  source         = "./modules/acr-with-pe"
  name_prefix    = "kube-registry"
  location       = azurerm_resource_group.kube-rg.location
  resource_group = azurerm_resource_group.kube-rg.name
  subnet_id      = module.kube-subnets["kube-registry"].subnet_id
  dns_zone_id    = module.kube-vnet.dns_zone_ids["azurecr.io"]
}

resource "azurerm_kubernetes_cluster" "kube-cluster" {
  name                = "kube-cluster"
  location            = azurerm_resource_group.kube-rg.location
  resource_group_name = azurerm_resource_group.kube-rg.name
  dns_prefix          = "mb-kube-cluster"
  node_resource_group = "kube-rg-infra"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

}