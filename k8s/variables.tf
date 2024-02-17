variable "eks_cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "eks_oidc_provider_url" {
  type        = string
  description = "EKS OIDC provider url"
}