# helm install my-argocd-apps argo/argocd-apps --version 2.0.1
resource "helm_release" "argocd_apps" {
  name             = "argocd-apps"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argocd-apps"
  namespace        = "argocd"
  create_namespace = true
  version          = "2.0.1"
  values           = [file("${path.module}/values/argocd-apps.yaml")]
  depends_on       = [helm_release.argocd]
}
