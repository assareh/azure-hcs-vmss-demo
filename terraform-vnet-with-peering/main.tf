provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "hashidemos" {
  count = var.create_demo_rg ? 1 : 0

  name     = var.demo_resource_group_name
  location = var.location
  tags     = local.common_tags
}

data "azurerm_resource_group" "hashidemos" {
  name = var.demo_resource_group_name
}

resource "azurerm_virtual_network" "main" {
  name                = "main"
  address_space       = ["192.168.0.0/16"]
  location            = data.azurerm_resource_group.hashidemos.location
  resource_group_name = data.azurerm_resource_group.hashidemos.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = data.azurerm_resource_group.hashidemos.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["192.168.1.0/24"]
}

provider "hcs" {}

data "hcs_cluster" "default" {
  resource_group_name      = var.hcs_resource_group_name
  managed_application_name = var.managed_application_name

  cluster_name = var.cluster_name
}

resource "azurerm_virtual_network_peering" "cluster-to-network" {
  name                      = "cluster-to-network"
  resource_group_name       = data.hcs_cluster.default.vnet_resource_group_name
  virtual_network_name      = data.hcs_cluster.default.vnet_name
  remote_virtual_network_id = azurerm_virtual_network.main.id
}

resource "azurerm_virtual_network_peering" "network-to-cluster" {
  name                      = "network-to-cluster"
  resource_group_name       = data.azurerm_resource_group.hashidemos.name
  virtual_network_name      = azurerm_virtual_network.main.name
  remote_virtual_network_id = data.hcs_cluster.default.vnet_id
}
