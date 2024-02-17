resource "aws_iam_policy" "cert_manager" {
  name   = "AWSCertManagerIAMPolicy"
  policy = file("${path.module}/policies/permissions-policy.json")
}

resource "aws_iam_role" "cert_manager" {
  name = "AmazonEKSCertManagerRole"
  assume_role_policy = templatefile("${path.module}/policies/trust-policy.json", {
    eks_oidc_provider = var.eks_oidc_provider
    eks_oidc_arn      = var.eks_oidc_provider_arn
  })
  managed_policy_arns = [aws_iam_policy.cert_manager.arn]
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  force_update     = true
  version          = "~> 1.12.0"
  values = [
    templatefile("${path.module}/values.yaml", {
      cert_manager_iam_role = aws_iam_role.cert_manager.arn
    })
  ]
}