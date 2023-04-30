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
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
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

provider "kubectl" {
  host                   = var.kubernetes_host
  token                  = var.kubernetes_token
  cluster_ca_certificate = base64decode(var.kubernetes_certificate)
  load_config_file       = false
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

resource "kubernetes_namespace" "sealed-secrets" {
  metadata {
    name = "sealed-secrets"
  }
}

resource "kubernetes_namespace" "reloader" {
  metadata {
    name = "reloader"
  }
}

resource "kubernetes_secret" "selead_secret_secret" {
  data = {
    "tls.crt" = var.sealed-secret-cert
    "tls.key" = var.sealed-secret-key
  }
  metadata {
    namespace = "sealed-secrets"
    name      = "sealed-secrets-key"
    labels = {
      "sealedsecrets.bitnami.com/sealed-secrets-key" = "active"
    }
  }
  type = "kubernetes.io/tls"

  depends_on = [
    kubernetes_namespace.sealed-secrets
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

  set {
    name  = "configs.cm.admin\\.enabled"
    value = "true"
  }

  set {
    name  = "configs.secret.argocdServerAdminPassword"
    value = var.argocd_password
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
    name  = "repo_url_encoded"
    value = base64encode("git@github.com:${var.github_repo_owner}/${var.github_argocd_repo}.git")
  }

  set {
    name  = "repo_private_key_encoded"
    value = base64encode(var.github_private_key)
  }

  set {
    name  = "docker_config_encoded"
    value = base64encode("${var.dockerhub_username}:${var.dockerhub_password}")
  }
}

resource "helm_release" "argocd-image-updater" {
  name       = "argocd-image-updater"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-image-updater"
  namespace  = "argocd"

  depends_on = [
    helm_release.argocd-base
  ]

  set {
    name  = "createCustomResource"
    value = "true"
  }

  set {
    name  = "installCRDs"
    value = "true"
  }

  values = [
    <<EOT
    config:
      registries:
        - name: "Docker Hub"
          prefix: "docker.io"
          api_url: "https://registry-1.docker.io"
          credentials: "secret:argocd/dockerhub-credentials#credentials"
          defaultns: "library"
          default: true
    EOT
  ]
}

resource "helm_release" "sealed-secrets" {
  name       = "sealed-secrets"
  repository = "https://bitnami-labs.github.io/sealed-secrets"
  chart      = "sealed-secrets"
  namespace  = "sealed-secrets"

  depends_on = [
    kubernetes_secret.selead_secret_secret
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

resource "helm_release" "reloader" {
  name       = "reloader"
  repository = "https://stakater.github.io/stakater-charts"
  chart      = "reloader"
  namespace  = "reloader"

  depends_on = [
    kubernetes_namespace.reloader
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

resource "kubectl_manifest" "projects" {
  for_each  = toset(split("\n---\n", var.projects-yaml))
  yaml_body = each.key

  depends_on = [
    helm_release.argocd-base
  ]
}

resource "time_sleep" "wait-for-10-mins-for-argocd-cleanup" {
  destroy_duration = "10m"

  depends_on = [
    kubectl_manifest.projects
  ]
}

resource "kubectl_manifest" "init" {
  for_each  = toset(split("\n---\n", var.init-yaml))
  yaml_body = each.key

  depends_on = [
    time_sleep.wait-for-10-mins-for-argocd-cleanup
  ]
}
