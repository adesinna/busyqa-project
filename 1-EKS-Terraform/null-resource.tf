resource "null_resource" "kube-config" {
  depends_on = [aws_eks_node_group.eks_ng_private]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.eks_cluster.name}"
  }
}
