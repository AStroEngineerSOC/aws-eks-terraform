resource "aws_iam_user" "developer" {
  name = "developer"
}

resource "aws_iam_policy" "developer_eks" {
  name        = "AmazonEKSDeveloperPolicy"
  description = "TF generated"
  policy      = file("${path.module}/iam/AmazonEKSDeveloperPolicy.json")
}

resource "aws_iam_user_policy_attachment" "developer_eks" {
  user       = aws_iam_user.developer.name
  policy_arn = aws_iam_policy.developer_eks.arn
}

resource "kubectl_manifest" "viewer-cluster-role" {
  yaml_body = file("${path.module}/kubectl_manifest/viewer-cluster-role.yaml")
}

resource "kubectl_manifest" "viewer-cluster-role-binding" {
  yaml_body  = file("${path.module}/kubectl_manifest/viewer-cluster-role-binding.yaml")
  depends_on = [kubectl_manifest.viewer-cluster-role]
}

resource "aws_eks_access_entry" "developer" {
  cluster_name      = aws_eks_cluster.eks.name
  principal_arn     = aws_iam_user.developer.arn
  kubernetes_groups = ["viewer"]
  depends_on        = [kubectl_manifest.viewer-cluster-role-binding]
}
