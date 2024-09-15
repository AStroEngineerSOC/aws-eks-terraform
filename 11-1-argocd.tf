resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.5.2"
  values           = [file("${path.module}/values/argocd.yaml")]
  depends_on       = [aws_eks_node_group.general]
}
