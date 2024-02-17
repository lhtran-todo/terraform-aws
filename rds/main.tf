locals {
  rds_name = "${var.app_name}-${var.env}-rds"
}
data "aws_availability_zones" "us_east_1" {
}
module "rds" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 9.0.0"

  name           = local.rds_name
  engine         = var.rds_engine # This uses RDS engine, not Aurora
  engine_version = var.rds_version

  database_name               = "${var.app_name}${var.env}db"
  master_username             = "${var.app_name}${var.env}"
  manage_master_user_password = true
  port                        = var.rds_port

  vpc_id               = var.vpc_id
  db_subnet_group_name = var.rds_subnet_group_name

  allocated_storage         = var.rds_storage
  db_cluster_instance_class = var.rds_instance_type
  iops                      = var.rds_iops
  storage_type              = "io1"


  #   maintenance_window = "Mon:00:00-Mon:03:00"
  #   backup_window      = "03:00-06:00"

  #   backup_retention_period = 0


  skip_final_snapshot   = true
  create_security_group = true
  security_group_rules = {
    eks_default_ng = {
      type                     = "ingress"
      from_port                = var.rds_port
      to_port                  = var.rds_port
      source_security_group_id = var.allow_security_group_id
    }
  }

  #tags = local.tags
}

resource "aws_ssm_parameter" "rds_connections" {
  name        = "/todo/rds/connections"
  description = "RDS write/read endpoint"
  type        = "String"
  value       = "{\"db_name\":\"${module.rds.cluster_database_name}\",\"primary_endpoint\":\"${module.rds.cluster_endpoint}\",\"reader_endpoint\":\"${module.rds.cluster_reader_endpoint}\"}"
}
data "aws_iam_openid_connect_provider" "this" {
  url = var.eks_oidc_provider_url
}
resource "aws_iam_policy" "rds_secret" {
  name = "TodoRDSSecretIAMPolicy"
  policy = templatefile("${path.module}/policies/permissions-policy.json", {
    secret_arn    = module.rds.cluster_master_user_secret[0].secret_arn,
    ssm_param_arn = aws_ssm_parameter.rds_connections.arn
  })
}
resource "aws_iam_role" "rds_secret" {
  name = "TodoServiceAccountDBSecretRole"
  assume_role_policy = templatefile("${path.module}/policies/trust-policy.json", {
    eks_oidc_provider = data.aws_iam_openid_connect_provider.this.url
    eks_oidc_arn      = data.aws_iam_openid_connect_provider.this.arn
  })
  managed_policy_arns = [aws_iam_policy.rds_secret.arn]
}