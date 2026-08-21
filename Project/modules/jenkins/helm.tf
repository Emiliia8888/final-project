resource "helm_release" "jenkins" {

  name = "jenkins"

  repository = "https://charts.jenkins.io"

  chart = "jenkins"

  namespace = kubernetes_namespace_v1.jenkins.metadata[0].name

  create_namespace = false

  values = [
    file("${path.module}/values.yaml")
  ]

  timeout = 600

  wait = true

  depends_on = [
    kubernetes_namespace_v1.jenkins
  ]
}
