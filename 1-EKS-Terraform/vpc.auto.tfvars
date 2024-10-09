# VPC Variables
vpc_name = "myvpc"
vpc_cidr_block = "172.0.0.0/16"
#vpc_availability_zones = ["us-east-1a", "us-east-1b"]
vpc_public_subnets = ["172.0.1.0/24", "172.0.2.0/24"]
vpc_private_subnets = ["172.0.3.0/24", "172.0.4.0/24"]
vpc_database_subnets= ["172.0.5.0/24", "172.0.6.0/24"]
vpc_create_database_subnet_group = false
vpc_create_database_subnet_route_table = false
vpc_enable_nat_gateway = true  
vpc_single_nat_gateway = true