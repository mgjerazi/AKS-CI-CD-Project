terraform {

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.86.0"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.6.1"
    }

    helm = {
      source = "hashicorp/helm"
    }
  }

}

provider "azurerm" {
  # Configuration options
  features {}
}


resource "azurerm_resource_group" "merkato_rg" {
  name     = "merkato_rg"
  location = "westeurope"

  tags = {
    environment = "Demo"
  }
}

resource "azurerm_kubernetes_cluster" "MerkatoCluster" {
  name                = "MerkatoCluster"
  location            = azurerm_resource_group.merkato_rg.location
  resource_group_name = azurerm_resource_group.merkato_rg.name
  dns_prefix          = "MerkatoClusterAKS"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_DS2_v2"
    type            = "VirtualMachineScaleSets"
    os_disk_size_gb = 30
    availability_zones  = [1, 2, 3]
    enable_auto_scaling = false
  }


  identity {
    type = "SystemAssigned"
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "kubenet"
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
    environment = "PROD"
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

resource "kubernetes_namespace" "production" {
  metadata {
    name = "production"
  }
}
#Backend Deployments

resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "quiz-backend-update"
    namespace = "production"
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "quiz-backend-update"
      }
    }
    template {
      metadata {
        labels = {
          app = "quiz-backend-update"
        }
      }
      spec {

        container {
          image             = "mariolgjerazi/backendquiz:latest"
          name              = "quiz-backend-update"
          image_pull_policy = "Always"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "backendservice" {
  metadata {
    name      = "quiz-backend-update"
    namespace = "production"
  }
  spec {
    type     = "ClusterIP"
    port {
      port        = 8080
      target_port = "8080"
    }
    selector = {
      app = "quiz-backend-update"
    }
  }
}
#Frontend deployments

resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "frontend"
    namespace = "production"
  }
  spec {
    replicas = 2
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
          image             = "mariolgjerazi/frontendquiz:latest"
          name              = "frontend"
          image_pull_policy = "Always"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "frontendservice" {
  metadata {
    name      = "frontend"
    namespace = "production"
  }
  spec {
    type     = "ClusterIP"
    port {
      port        = 80
      target_port = "80"
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
  namespace  = "production"
  timeout    = 300

}


resource "kubernetes_ingress" "ingress-front-back" {
  metadata {
    labels      = {
      app = "ingress-nginx"
    }
    name        = "ingress-front-back"
    namespace   = "production"
    annotations = {
      "kubernetes.io/ingress.class" : "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect" : "false"
      "nginx.ingress.kubernetes.io/use-regex" : "true"
      "nginx.ingress.kubernetes.io/rewrite-target" : "/$1"
    }
  }

  spec {
    rule {
      http {
        path {
          backend {
            service_name = "quiz-backend-update"
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