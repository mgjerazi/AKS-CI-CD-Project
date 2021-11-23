terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "merkato_gr" {
  name     = "merkato_gr"
  location = "westeurope"

  tags = {
    environment = "testing"
  }
}

resource "azurerm_kubernetes_cluster" "MerkatoCluster" {
  name                = "MerkatoCluster"
  location            = azurerm_resource_group.merkato_gr.location
  resource_group_name = azurerm_resource_group.merkato_gr.name
  dns_prefix          = "MerkatoClusterDNS-k8s"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 30
  }

  identity {
    type = "SystemAssigned"
  }

  addon_profile {
    http_application_routing {
      enabled = true
    }
  }

  /*
  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }
  */

  role_based_access_control {
    enabled = true
  }

  tags = {
    environment = "AKS"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "kubernetes_namespace" "dev" {
  metadata {
    name = "dev"
  }
}

#Backend Deployments

resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "backend"
    namespace = "dev"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "backend"
        tier = "backend"
      }
    }
    template {
      metadata {
        labels = {
          app = "backend"
          tier = "backend"
        }
      }
      spec {

        container {
          image   = "mariolgjerazi/backendquiz:latest"
          name    = "backend"
          image_pull_policy = "Always"
          port {
            container_port = 8080
            name = "http"
            protocol = "TCP"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "backend" {
  metadata {
    name = "backend"
    namespace = "dev"
  }
  spec {
    type = "ClusterIP"
    port {
      port        = 8080
      protocol    = "TCP"
      target_port = "8080"
    }
    selector = {
      app = "backend"
      tier = "backend"
    }
  }
}
#Frontend deployments

resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "frontend"
    namespace = "dev"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "frontend"
      }
    }
    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }
      spec {

        container {
          image   = "mariolgjerazi/frontendquiz:latest"
          name    = "frontend"
          image_pull_policy = "Always"
          port {
            container_port = 80
            protocol = "TCP"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name = "frontend"
    namespace = "dev"
  }
  spec {
    type = "ClusterIP"
    port {
      port        = 80
      target_port = "80"
      protocol    = "TCP"
    }
    selector = {
      app = "frontend"
    }
  }
}

# Ingress

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "dev"
  timeout    = 300

}


resource "kubernetes_ingress" "ingress" {
  metadata {
    labels                = {
      app = "ingress-nginx"
    }
    name = "ingress-nginx-front-back-update"
    namespace = "dev"
    annotations = {
      "kubernetes.io/ingress.class": "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect": "false"
      "nginx.ingress.kubernetes.io/use-regex": "true"
      "nginx.ingress.kubernetes.io/rewrite-target": "/$1"
    }
  }

  spec {
    backend {
      service_name = "frontend"
      service_port = "80"
    }
    rule {
      http {
        path {
          backend {
            service_name = "backend"
            service_port = 8080
          }

          path = "/api/quiz/select?(.*)"
        }

        path {
          backend {
            service_name = "frontend"
            service_port = 80
          }

          path = "/?(.*)"
        }
      }
    }
  }
}