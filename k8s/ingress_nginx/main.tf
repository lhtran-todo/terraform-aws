resource "helm_release" "ingres_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "~> 4.9"
  values = [
    "${file("${path.module}/values.yaml")}"
  ]
}