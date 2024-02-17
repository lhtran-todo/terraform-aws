variable "region" {
  type        = string
  description = "Region to deploy VPC"
  validation {
    condition     = contains(["us-east-1", "us-east-2", "us-west-1", "us-west-2"], var.region)
    error_message = "Region must be in us-east-1, us-east-2, us-west-1, or us-west-2"
  }
}
variable "tag_owner" {
  type        = string
  description = "Who own the resource"
}
variable "tag_managed-by" {
  type        = string
  description = "Which tool to manage the resource"
  validation {
    condition     = contains(["terraform", "console", "cli"], var.tag_managed-by)
    error_message = "Environment must be terraform, console or cli"
  }
}
variable "env" {
  type        = string
  description = "Environment"
  validation {
    condition     = contains(["prod", "dev", "test", "stg"], var.env)
    error_message = "Environment must be prod, dev, stg or test"
  }
}
variable "app_name" {
  type        = string
  description = "App name"
}
variable "eks_version" {
  type        = string
  description = "EKS cluster version"
}
variable "vpc_name" {
  type        = string
  description = "VPC id to deploy"
}
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR to deploy"
}
variable "nodegroup_instance_type" {
  type        = list(any)
  default     = ["t3.medium"]
  description = "Nodegroup instance type list"
}
variable "nodegroup_vol_size" {
  type        = number
  default     = 30
  description = "Nodegroup instance size"
}
variable "eks_access_entries" {
  type        = any
  default     = {}
  description = "Access entries to authenticate to the cluster"
}
variable "kms_key_arn" {
  type        = string
  description = "KMS key arn for cluster encryption"
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