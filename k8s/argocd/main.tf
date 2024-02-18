resource "helm_release" "argo" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argo"
  create_namespace = true
  version          = "~> 6.0"
  values = [
    "${file("${path.module}/values.yaml")}"
  ]
  # # An option for setting values that I generally use
  # values = [jsonencode({
  #   someKey = "someValue"
  # })]
}