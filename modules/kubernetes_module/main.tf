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

resource "kubernetes_namespace" "letsencrypt" {
  metadata {
    name = "letsencrypt"
  }
}

resource "kubernetes_secret" "dex-secret" {
  metadata {
    name      = "dex-secret-github"
    namespace = "argocd"
    labels = {
      "app.kubernetes.io/component" = "server"
      "app.kubernetes.io/instance"  = "argocd"
      "app.kubernetes.io/name"      = "dex-secret-github"
      "app.kubernetes.io/part-of"   = "argocd"
    }
  }
  data = {
    clientID : var.github_oauth_app_client_id
    clientSecret : var.github_oauth_app_client_secret
  }

  depends_on = [
    kubernetes_namespace.argocd
  ]
}


resource "helm_release" "nginx-ingress-chart" {
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
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-name"
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
  version    = "v1.11"
  namespace  = "letsencrypt"
  timeout    = 120

  depends_on = [
    kubernetes_namespace.letsencrypt
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


resource "helm_release" "cluster-issuer" {
  name      = "cluster-issuer"
  chart     = "./charts/cluster-issuer"
  namespace = "letsencrypt"

  depends_on = [
    helm_release.cert-manager
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
    kubernetes_namespace.argocd,
    kubernetes_secret.dex-secret
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

resource "helm_release" "argocd-base" {
  name                       = "argocd-base"
  chart                      = "./charts/argocd-base"
  namespace                  = "argocd"
  disable_openapi_validation = true

  depends_on = [
    helm_release.argocd
  ]

  set {
    name  = "createCustomResource"
    value = "true"
  }

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "domain"
    value = var.domain
  }

  set {
    name  = "repo_url"
    value = "git@github.com:${var.github_repo_owner}/${var.github_argocd_repo}.git"
  }

  set {
    name  = "repo_url_encoded"
    value = base64encode("git@github.com:${var.github_repo_owner}/${var.github_argocd_repo}.git")
  }

  set {
    name  = "repo_private_key_encoded"
    value = base64encode(var.github_private_key)
  }
}
