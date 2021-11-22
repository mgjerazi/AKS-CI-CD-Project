terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

resource "random_pet" "prefix" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "merkato_group" {
  name     = "merkato_group"
  location = "westeurope"

  tags = {
    environment = "Demo"
  }
}

resource "azurerm_kubernetes_cluster" "randomClusterMerkato" {
  name                = "randomClusterMerkato"
  location            = azurerm_resource_group.merkato_group.location
  resource_group_name = azurerm_resource_group.merkato_group.name
  dns_prefix          = "${random_pet.prefix.id}-k8s"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 30
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
    environment = "Demo"
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

resource "kubernetes_namespace" "final-project" {
  metadata {
    name = "final-project"
  }
}
#Backend Deployments

resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "quiz-backend-update"
    namespace = "final-project"
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
          image             = "mariolgjerazi/backendquiz"
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
    namespace = "final-project"
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
    namespace = "final-project"
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
          image             = "mariolgjerazi/frontendquiz"
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

resource "kubernetes_service" "frontend" {
  metadata {
    name      = "frontend"
    namespace = "final-project"
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
  namespace  = "final-project"
  timeout    = 300

}


resource "kubernetes_ingress" "ingress-front-back" {
  metadata {
    labels      = {
      app = "ingress-nginx"
    }
    name        = "ingress-front-back"
    namespace   = "final-project"
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