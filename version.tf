terraform {
  required_version = "~> 1.7"
  cloud {
    organization = "lhtran" # export TF_CLOUD_ORGANIZATION='lhtran'

    workspaces {
      name = "lhtran-todo-dev" # export TF_WORKSPACE='lhtran-todo-cf-frontend-dev'
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7"
    }
  }
}