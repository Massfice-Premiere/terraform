terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }

}

provider "helm" {
  kubernetes {
    host                   = var.kubernetes_host
    token                  = var.kubernetes_token
    cluster_ca_certificate = base64decode(var.kubernetes_certificate)
  }
}

provider "kubernetes" {
  host                   = var.kubernetes_host
  token                  = var.kubernetes_token
  cluster_ca_certificate = base64decode(var.kubernetes_certificate)
}

resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}


resource "helm_release" "nginx_ingress_chart" {
  name       = "nginx-ingress-controller"
  namespace  = "ingress"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"

  depends_on = [
    kubernetes_namespace.ingress
  ]

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "service.annotations.kubernetes\\.digitalocean\\.com/load-balancer-id"
    value = var.loadbalancer_id
  }

  set {
    name  = "service.annotations.kubernetes\\.digitalocean\\.com/load-balancer-name"
    value = var.loadbalancer_name
  }

  set {
    name  = "service.annotations.helm\\.sh/resource-policy"
    value = "keep"
  }
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.0.1"
  namespace  = "kube-system"
  timeout    = 120

  set {
    name  = "createCustomResource"
    value = "true"
  }

  set {
    name  = "installCRDs"
    value = "true"
  }
}


resource "helm_release" "cluster-issuer" {
  name      = "cluster-issuer"
  chart     = "./charts/cluster-issuer"
  namespace = "kube-system"

  depends_on = [
    helm_release.cert-manager,
  ]

  set {
    name  = "letsencrypt_email"
    value = var.letsencrypt_email
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"

  depends_on = [
    kubernetes_namespace.argocd
  ]

  set {
    name  = "createCustomResource"
    value = "true"
  }

  set {
    name  = "installCRDs"
    value = "true"
  }
}
