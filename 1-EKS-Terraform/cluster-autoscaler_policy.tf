resource "aws_iam_policy" "autoscaler_policy" {
  name        = "AutoscalerPolicy"
  description = "Policy for EC2 Instances to allow Cluster Autoscaler actions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeTags",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeAutoScalingGroups",
          "ec2:UpdateAutoScalingGroup",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:DescribeTags"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "attach_autoscaler_policy" {
  name       = "attach-autoscaler-policy"
  policy_arn = aws_iam_policy.autoscaler_policy.arn
  roles      = [aws_iam_role.eks_nodegroup_role.name]
}
