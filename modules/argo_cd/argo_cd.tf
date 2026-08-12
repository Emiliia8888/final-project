resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
}

# Створюємо сервіс LoadBalancer, щоб отримати посилання на адмінку
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
    type                = "LoadBalancer"
    load_balancer_class = "service.k8s.aws/nlb"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.7.7"

  namespace = kubernetes_namespace_v1.argocd.metadata[0].name

  depends_on = [
    kubernetes_namespace_v1.argocd
  ]
}

resource "helm_release" "django_app" {
  name      = "django-app"
  chart     = "${path.module}/charts"
  version   = "0.1.0"
  namespace = kubernetes_namespace_v1.argocd.metadata[0].name

  wait         = true
  timeout      = 300
  force_update = true
  depends_on = [
    helm_release.argocd
  ]
}
