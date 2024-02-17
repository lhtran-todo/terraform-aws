data "aws_iam_openid_connect_provider" "this" {
  url = var.eks_oidc_provider_url
}

module "k8s_aws_lb_ctrl" {
  source                = "./aws_lb_ctrl"
  eks_cluster_name      = var.eks_cluster_name
  eks_oidc_provider     = data.aws_iam_openid_connect_provider.this.url
  eks_oidc_provider_arn = data.aws_iam_openid_connect_provider.this.arn
}

module "k8s_cert_manager" {
  depends_on            = [module.k8s_aws_lb_ctrl]
  source                = "./cert_manager"
  eks_oidc_provider     = data.aws_iam_openid_connect_provider.this.url
  eks_oidc_provider_arn = data.aws_iam_openid_connect_provider.this.arn
}

module "k8s-ingress-nginx" {
  depends_on = [module.k8s_aws_lb_ctrl]
  source     = "./ingress_nginx"
}

module "k8s-argocd" {
  depends_on = [module.k8s-ingress-nginx, module.k8s_cert_manager]
  source     = "./argocd"
}

module "secrets_store_csi" {
  depends_on = [module.k8s_aws_lb_ctrl]
  source     = "./secrets_store_csi"
}