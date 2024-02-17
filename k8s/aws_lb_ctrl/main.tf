locals {
  service_account_name = "aws-load-balancer-controller"
}

resource "aws_iam_policy" "aws_load_balancer" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("${path.module}/policies/permissions-policy.json")
}

resource "aws_iam_role" "aws_load_balancer" {
  name = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = templatefile("${path.module}/policies/trust-policy.json", {
    eks_oidc_provider = var.eks_oidc_provider
    eks_oidc_arn      = var.eks_oidc_provider_arn
  })
  managed_policy_arns = [aws_iam_policy.aws_load_balancer.arn]
}

resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "~> 1.7"

  values = [
    templatefile("${path.module}/values.yaml", {
      eks_cluster_name     = var.eks_cluster_name
      service_account_name = local.service_account_name
      role_arn             = aws_iam_role.aws_load_balancer.arn
    })
  ]
}