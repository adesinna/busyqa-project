//# Step 1: Create the IAM Role for EBS CSI Driver Controller
//resource "aws_iam_role" "ebs_csi_driver_role" {
//  name = "${aws_eks_cluster.eks_cluster.name}-ebs-csi-driver-controller-role"
//
//  assume_role_policy = jsonencode({
//    Version = "2012-10-17",
//    Statement = [
//      {
//        Effect = "Allow",
//        Principal = {
//          Service = "eks.amazonaws.com"
//        },
//        Action = "sts:AssumeRole"
//      }
//    ]
//  })
//}

resource "aws_iam_policy_attachment" "attach_amazon_ebs_csi_driver" {
  name       = "attach-amazon-ebs-csi-driver"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy" # this policy is already on Amazon
  roles      = [aws_iam_role.eks_nodegroup_role.name]
}



# Create IAM role for auto-scaler
resource "aws_iam_role" "cluster_autoscaler_role" {
  name = "${aws_eks_cluster.eks_cluster.name}-autoscaler-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = ["sts:AssumeRole", "sts:TagSession"]
        Principal = { Service = "pods.eks.amazonaws.com" }
      }
    ]
  })
}

# Create the policy
resource "aws_iam_policy" "cluster_autoscaler_policy" {
  name   = "${aws_eks_cluster.eks_cluster.name}-autoscaler-policy"
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "eks:DescribeNodegroup",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "ec2:DescribeInstances",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]
        Resource = "*"
      }
    ]
  })
}

# attach policy to the role

resource "aws_iam_policy_attachment" "attach-cluster-autoscaler" {
  name       = "attach-cluster-autoscaler"
  policy_arn = aws_iam_policy.cluster_autoscaler_policy.arn
  roles      = [aws_iam_role.cluster_autoscaler_role.name, aws_iam_role.eks_nodegroup_role.name]
}


# associate the IAM Role with the service account
resource "aws_eks_pod_identity_association" "cluster_autoscaler_association" {
  depends_on      = [aws_eks_node_group.eks_ng_private]

  cluster_name    = aws_eks_cluster.eks_cluster.name
  namespace       = "kube-system"
  service_account = "default"
  role_arn        = aws_iam_role.cluster_autoscaler_role.arn

}
