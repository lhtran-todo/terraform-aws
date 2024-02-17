variable "app_name" {
  type        = string
  description = "App name"
}
variable "env" {
  type        = string
  description = "Environment"
  validation {
    condition     = contains(["prod", "dev", "test", "stg"], var.env)
    error_message = "Environment must be prod, dev, stg or test"
  }
}
variable "rds_version" {
  type        = string
  description = "RDS version"
}
variable "rds_engine" {
  type        = string
  description = "RDS Engine"
}
variable "rds_instance_type" {
  type        = string
  description = "RDS Instance type"
}
variable "rds_storage" {
  type        = number
  description = "RDS Storage"
}
variable "rds_iops" {
  type        = number
  description = "RDS IOPS"
}
variable "rds_port" {
  type        = number
  description = "RDS port"
}
variable "rds_subnet_group_name" {
  type        = string
  description = "RDS port"
}
variable "allow_security_group_id" {
  type        = string
  description = "The security group of EKS nodegroup to allow access to RDS"
}
variable "vpc_id" {
  type        = string
  description = "VPC id to deploy"
}
variable "eks_oidc_provider_url" {
  type        = string
  description = "EKS OIDC provider url"
}