data "aws_vpc" "selected" {
  tags = {
    Name = var.vpc_name
  }
  cidr_block = var.vpc_cidr
}

module "eks" {
  source                  = "./eks"
  app_name                = var.app_name
  eks_version             = var.eks_version
  tag_owner               = var.tag_owner
  tag_managed-by          = var.tag_managed-by
  env                     = var.env
  vpc_id                  = data.aws_vpc.selected.id
  nodegroup_instance_type = var.nodegroup_instance_type
  nodegroup_vol_size      = var.nodegroup_vol_size
  eks_access_entries      = var.eks_access_entries
  kms_key_arn             = var.kms_key_arn

}

data "aws_eks_cluster" "this" {
  depends_on = [module.eks.cluster_name]
  name       = module.eks.cluster_name
}

module "k8s" {
  depends_on            = [module.eks]
  source                = "./k8s"
  eks_cluster_name      = module.eks.cluster_name
  eks_oidc_provider_url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

data "aws_route53_zone" "lhtran_net" {
  name = "lhtran.net."
}
data "aws_lb" "ingress_nginx" {
  depends_on = [module.k8s]
  tags = {
    "elbv2.k8s.aws/cluster"    = "${module.eks.cluster_name}"
    "service.k8s.aws/resource" = "LoadBalancer"
    "service.k8s.aws/stack"    = "ingress-nginx/ingress-nginx-controller"
  }
}
resource "aws_route53_record" "argocd" {
  zone_id = data.aws_route53_zone.lhtran_net.zone_id
  name    = "argocd.lhtran.net"
  type    = "A"

  alias {
    name                   = data.aws_lb.ingress_nginx.dns_name
    zone_id                = data.aws_lb.ingress_nginx.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "todo" {
  zone_id = data.aws_route53_zone.lhtran_net.zone_id
  name    = "dev.todo.lhtran.net"
  type    = "A"

  alias {
    name                   = data.aws_lb.ingress_nginx.dns_name
    zone_id                = data.aws_lb.ingress_nginx.zone_id
    evaluate_target_health = true
  }
}

module "rds" {
  source                  = "./rds"
  app_name                = var.app_name
  rds_engine              = var.rds_engine
  rds_version             = var.rds_version
  rds_port                = var.rds_port
  rds_subnet_group_name   = var.rds_subnet_group_name
  rds_storage             = var.rds_storage
  rds_instance_type       = var.rds_instance_type
  rds_iops                = var.rds_iops
  env                     = var.env
  allow_security_group_id = module.eks.nodegroup_security_group_id
  vpc_id                  = data.aws_vpc.selected.id
  eks_oidc_provider_url   = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}