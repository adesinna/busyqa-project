# Input Variables that would be generic
# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type = string
  default = "us-west-2"
}

# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type = string
  default = "busyqa"
}

# Cluster name Variable
variable "cluster_name" {
  description = "Name of the eks cluster"
  type = string
  default = "eksproject"
}

