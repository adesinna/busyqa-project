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
  depends_on = [aws_eks_node_group.eks_ng_private, null_resource.kube-config]

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


  set {
    name  = "autoDiscovery.clusterName"
    value = aws_eks_cluster.eks_cluster.name
  }

  # MUST be updated to match your region
  set {
    name  = "awsRegion"
    value = var.aws_region
  }
    set {
    name  = "nodeGroups[0].minNodes"
    value = "2"  # Minimum number of nodes in the node group
  }

  set {
    name  = "nodeGroups[0].maxNodes"
    value = "5"  # Maximum number of nodes in the node group
  }

}