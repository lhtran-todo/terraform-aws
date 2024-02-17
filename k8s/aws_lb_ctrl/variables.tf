variable "eks_cluster_name" {
  type        = string
  description = "EKS cluster name"
}
variable "eks_oidc_provider" {
  type        = string
  description = "EKS OIDC provider"
}
variable "eks_oidc_provider_arn" {
  type        = string
  description = "EKS OIDC provider arn"
}