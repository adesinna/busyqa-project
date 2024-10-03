provider "helm" {
  kubernetes {
    config_path = "~/.kube/config" # Path to your kubeconfig file
  }
}

resource "helm_release" "metrics_server" {
  depends_on = [aws_eks_node_group.eks_ng_private, null_resource.kube-config]

  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.1"
}

resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress-nginx" {
  depends_on = [
    aws_eks_node_group.eks_ng_private,
    null_resource.kube-config,
    kubernetes_namespace.ingress_nginx
  ]

  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name # Referring to the correct namespace
  version    = "4.11.2"
}

resource "helm_release" "aws-ebs-csi-driver" {
  depends_on = [aws_eks_node_group.eks_ng_private, null_resource.kube-config]

  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver/"
  chart      = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  version    = "2.35.1"
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = "kube-system"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.13.0"

  set {
    name  = "installCRDs"
    value = "true"
  }


}

