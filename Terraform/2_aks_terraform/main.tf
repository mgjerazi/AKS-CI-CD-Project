resource "azurerm_resource_group" "main" {
  name     = "tf-rg-multi-k8s"
  location = "North Europe"
}

resource "azurerm_kubernetes_cluster" "main" {
  count = length(var.cluster_name)
  name                = var.cluster_name[count.index]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = var.cluster_name[count.index]

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}