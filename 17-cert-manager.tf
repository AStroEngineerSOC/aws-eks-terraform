resource "helm_release" "cert_manager" {
  name = "cert-manager"

  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.15.3"

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [helm_release.external_nginx]
}

resource "kubectl_manifest" "cluster-issuer" {
  yaml_body  = file("${path.module}/kubectl_manifest/cluster-issuer.yaml")
  depends_on = [helm_release.cert_manager]
}
