terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "github" {
  token = var.token
  owner = var.owner
}

resource "tls_private_key" "tls-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "github_user_ssh_key" "argocd-key" {
  title = "argocd-key"
  key   = tls_private_key.tls-key.public_key_openssh
}

resource "github_repository_webhook" "argocd-webhook" {
  repository = var.argocd-repo
  events     = ["push"]
  configuration {
    url          = "https://argocd.${var.cluster-domain}/api/webhook"
    content_type = "json"
  }
}

resource "github_repository_file" "application-yaml" {
  repository     = var.argocd-repo
  branch         = "main"
  file           = "apps/argocd/application.yaml"
  content        = <<EOF
  apiVersion: argoproj.io/v1alpha1
  kind: Application
  metadata:
    name: argocd-application
    namespace: argocd
  spec:
    project: apps
    source:
      repoURL: git@github.com:${var.owner}/${var.argocd-repo}.git
      targetRevision: HEAD
      path: apps/argocd
    destination:
      server: https://kubernetes.default.svc
      namespace: argocd
    syncPolicy:
      syncOptions:
        - CreateNamespace=true
      automated:
        selfHeal: true
        prune: true
  EOF
  commit_message = "Argo CD Application | application.yaml"
}

resource "github_repository_file" "ingress-yaml" {
  repository     = var.argocd-repo
  branch         = "main"
  file           = "apps/argocd/ingress.yaml"
  content        = <<EOF
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: ingress
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-production
      kubernetes.io/tls-acme: "true"
      nginx.ingress.kubernetes.io/ssl-passthrough: "true"
      nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
      kubernetes.io/ingress.class: nginx
  spec:
    rules:
      - host: argocd.${var.cluster-domain}
        http:
          paths:
            - path: /
              pathType: Prefix
              backend:
                service:
                  name: argocd-server
                  port:
                    name: https
  tls:
    - hosts:
        - argocd.${var.cluster-domain}
      secretName: argocd-tls
  EOF
  commit_message = "Argo CD Application | ingress.yaml"
}

