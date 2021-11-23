variable "cluster_name" {
  description = "Create k8s cluster names"
  type        = list(string)
  default     = ["tf-aks-quiz-test", "tf-aks-quiz-dev"]
}

variable "kubeconfig_name" {
  description = "Create k8s cluster names"
  type        = list(string)
  default     = ["config-quiz-test", "config-quiz-dev"]
}