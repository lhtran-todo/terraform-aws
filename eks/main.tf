data "aws_subnets" "public" {
  tags = {
    Name = "*public*"
  }
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:kubernetes.io/role/elb"
    values = ["1"]
  }
}
data "aws_subnets" "private" {
  tags = {
    Name = "*private*"
  }
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:kubernetes.io/role/internal-elb"
    values = ["1"]
  }
}

locals {
  eks_name = "${var.app_name}-${var.env}-eks"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.eks_name
  cluster_version = var.eks_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  enable_irsa = true

  cluster_addons = {
    coredns = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "PRESERVE"
      #resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "PRESERVE"
    }
    vpc-cni = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "PRESERVE"
      #resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = aws_iam_role.vpc_cni.arn
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_IP_TARGET           = "7"
          MINIMUM_IP_TARGET        = "16"
        }
      })
    }
  }
  create_kms_key = false
  cluster_encryption_config = {
    provider_key_arn = var.kms_key_arn
    resources        = ["secrets"]
  }

  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true
  access_entries                           = var.eks_access_entries

  vpc_id                   = var.vpc_id
  subnet_ids               = data.aws_subnets.public.ids //use data.aws_subnets.private.ids with NAT 
  control_plane_subnet_ids = data.aws_subnets.public.ids

  create_cluster_security_group = false
  create_node_security_group    = false

  # create_cluster_security_group         = true
  # create_node_security_group            = true
  # node_security_group_additional_rules = {
  #   node2node_traffic = {
  #     description                = "Allow node to node traffic"
  #     protocol                   = "-1"
  #     from_port                  = 0
  #     to_port                    = 0
  #     type                       = "ingress"
  #     self = true
  #   }
  # }
  # node_security_group_enable_recommended_rules = false

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    use_name_prefix                       = true
    instance_types                        = var.nodegroup_instance_type
    attach_cluster_primary_security_group = true
    create_security_group                 = false
    iam_role_attach_cni_policy            = true
    ebs_optimized                         = true
    disable_api_termination               = var.env == "prod" ? true : false
    enable_monitoring                     = false
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = var.nodegroup_vol_size
          volume_type           = "gp3"
          encrypted             = true
          delete_on_termination = true
        }
      }
    }
  }
  eks_managed_node_groups = {

    default_nodegroup = {
      name = "${local.eks_name}-ng"

      subnet_ids = data.aws_subnets.public.ids

      min_size     = 1
      max_size     = 4
      desired_size = 1

      capacity_type        = var.env == "prod" ? "ON_DEMAND" : "SPOT"
      force_update_version = true
      instance_types       = var.nodegroup_instance_type

      update_config = {
        max_unavailable_percentage = var.env == "prod" ? 25 : 100 # or set `max_unavailable`
      }
    }
  }
}

resource "aws_iam_role" "vpc_cni" {
  name = "AmazonEKSVPCCNIRole"
  assume_role_policy = templatefile("${path.module}/policies/vpc-cni-trust-policy.json", {
    eks_oidc_provider = module.eks.oidc_provider
    eks_oidc_arn      = module.eks.oidc_provider_arn
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
}