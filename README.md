# Todo AWS Infrastructure with Terraform

## Terraform
This module will provision:
- EKS:
-- AWS VPC CNI with network prefix
-- AWS Load Balancer Controller
-- Ingress-NGINX Controller
-- cert-manager
-- ArgoCD
-- Secrets Store CSI with AWS provider
- RDS MultiAZ Cluster:
-- DB credential in Secrets Manager
-- DB connection in SSM Parameter Store
- Route53:
-- ArgoCD and Todo record

Ingress-NGINX Controller will create a AWS Network LoadBalancer and TLS is terminated at the controller with `ingressClassName: nginx` and annotation `cert-manager.io/cluster-issuer: letsencrypt-lhtran-net-example`
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  namespace: todo
  name: ingress-todo
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-lhtran-net-example
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - todo.lhtran.net
    secretName: todo-lhtran-net-cert
  rules:
```