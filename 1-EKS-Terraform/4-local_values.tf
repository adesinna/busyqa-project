# Define Local Values in Terraform
// They allow you to combine variables, you also use local values 
locals {
  environment = var.environment
  name = "${var.environment}" # concatenating variables, this is why we use local values

  eks_cluster_name = "${local.name}-${var.cluster_name}"  
  
  common_tags = {
    
  environment = local.environment
  }
} 