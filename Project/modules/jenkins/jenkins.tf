resource "kubernetes_namespace_v1" "jenkins" {

  metadata {

    name = "jenkins"

  }

}


resource "kubernetes_service_account_v1" "jenkins" {

  metadata {

    name = "jenkins"

    namespace = kubernetes_namespace_v1.jenkins.metadata[0].name

  }

}


resource "kubernetes_role_v1" "jenkins" {

  metadata {

    name = "jenkins"

    namespace = kubernetes_namespace_v1.jenkins.metadata[0].name

  }


  rule {

    api_groups = [""]

    resources = [
      "pods",
      "pods/exec",
      "pods/log"
    ]

    verbs = [
      "create",
      "delete",
      "get",
      "list",
      "watch"
    ]

  }

}


resource "kubernetes_role_binding_v1" "jenkins" {

  metadata {

    name = "jenkins"

    namespace = kubernetes_namespace_v1.jenkins.metadata[0].name

  }


  role_ref {

    api_group = "rbac.authorization.k8s.io"

    kind = "Role"

    name = kubernetes_role_v1.jenkins.metadata[0].name

  }


  subject {

    kind = "ServiceAccount"

    name = kubernetes_service_account_v1.jenkins.metadata[0].name

    namespace = kubernetes_namespace_v1.jenkins.metadata[0].name

  }

}
