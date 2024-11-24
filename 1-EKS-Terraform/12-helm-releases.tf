resource "helm_release" "metrics_server" {
  depends_on = [aws_eks_node_group.eks_ng_private, null_resource.kube-config]

  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "metric-server"
  version    = "3.12.1"
  create_namespace = true
}

resource "helm_release" "aws-ebs-csi-driver" {
  depends_on = [
    aws_eks_node_group.eks_ng_private,
    null_resource.kube-config,
  ]

  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver/"
  chart      = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  version    = "2.35.1"

}

resource "helm_release" "ingress-nginx" {
  depends_on = [aws_eks_node_group.eks_ng_private, null_resource.kube-config]

  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  version    = "4.11.2"
  create_namespace = true
}

resource "helm_release" "cluster-autoscaler" {
  depends_on = [aws_eks_node_group.eks_ng_private, null_resource.kube-config, helm_release.metrics_server]

  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.40.0"
  values   = [file("${path.module}/helm-values/cluster-autoscaler-values.yaml")]
}

resource "helm_release" "wordpress" {
  depends_on = [
    aws_eks_node_group.eks_ng_private,
    null_resource.kube-config
  ]

  name             = "wordpress"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "wordpress"
  namespace        = "wordpress"
  version          = "24.0.4" # Replace with the desired version
  create_namespace = true
  values   = [file("${path.module}/helm-values/wordpress-values.yaml")]


}


# Prometheus and grafana installation using Helm, this repo installs both
resource "helm_release" "kube-prometheus-stack" {
  name              = "kube-prometheus-stack"
  repository        = "https://prometheus-community.github.io/helm-charts"
  chart             = "kube-prometheus-stack"
  namespace         = "monitor"
  version           = "66.0.0"
  create_namespace  = true
}
