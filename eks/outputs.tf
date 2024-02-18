output "cluster_name" {
  value = module.eks.cluster_name
}

output "eks_version" {
  value = module.eks.cluster_version
}

output "nodegroup_security_group_id" {
  value = module.eks.cluster_primary_security_group_id
}