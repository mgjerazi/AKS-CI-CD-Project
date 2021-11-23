resource "local_file" "kubeconfig" {
  count = length(var.kubeconfig_name)
  filename     = var.kubeconfig_name[count.index]
  content      = azurerm_kubernetes_cluster.main[count.index].kube_config_raw
}