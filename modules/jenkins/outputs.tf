output "jenkins_namespace" {
  description = "Jenkins namespace"
  value       = kubernetes_namespace_v1.jenkins.metadata[0].name
}

output "jenkins_release_name" {
  description = "Jenkins deployment name"
  value       = kubernetes_deployment_v1.jenkins.metadata[0].name
}

output "jenkins_service_account" {
  description = "Jenkins Kubernetes service account"
  value       = kubernetes_service_account_v1.jenkins.metadata[0].name
}
