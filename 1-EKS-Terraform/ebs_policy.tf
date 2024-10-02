resource "aws_iam_policy" "amazon_ebs_csi_driver" {
  name        = "Amazon_EBS_CSI_Driver"
  description = "Policy for EC2 Instances to access Elastic Block Store"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ec2:AttachVolume",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteSnapshot",
        "ec2:DeleteTags",
        "ec2:DeleteVolume",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshots",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DetachVolume"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_policy_attachment" "attach_amazon_ebs_csi_driver" {
  name       = "attach-amazon-ebs-csi-driver"
  policy_arn = aws_iam_policy.amazon_ebs_csi_driver.arn
  roles      = [aws_iam_role.eks_nodegroup_role.name]
}



