output "namespace" {
  value = kubernetes_namespace_v1.argocd.metadata[0].name
}

output "service_name" {
  value = kubernetes_service_v1.argocd_server_lb.metadata[0].name
}
