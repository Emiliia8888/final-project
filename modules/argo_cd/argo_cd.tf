resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
}


resource "helm_release" "argocd" {
  name      = "argocd"
  namespace = kubernetes_namespace_v1.argocd.metadata[0].name

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.7.7"

  wait = true

  depends_on = [
    kubernetes_namespace_v1.argocd
  ]
}


resource "helm_release" "django_app" {
  name      = "django-app"
  namespace = kubernetes_namespace_v1.argocd.metadata[0].name

  chart = "${path.module}/charts"

  force_update = true
  wait = true

  depends_on = [
    helm_release.argocd
  ]
}


resource "kubernetes_service_v1" "argocd_server_lb" {
  metadata {
    name      = "argocd-server-external"
    namespace = kubernetes_namespace_v1.argocd.metadata[0].name
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "argocd-server"
    }

    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }

}
