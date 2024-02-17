output "cluster_name" {
  value = module.eks.cluster_name
}

output "nodegroup_security_group_id" {
  value = module.eks.cluster_primary_security_group_id
}