# provider "aws" {
#   region = var.region
# }

# data "aws_caller_identity" "current" {}




# ################################################################################
# # Supporting Resources
# ################################################################################

# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "5.1.2"

#   name = local.name
#   cidr = local.vpc_cidr

#   azs             = local.azs
#   public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
#   private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

#   enable_nat_gateway   = true
#   single_nat_gateway   = true
#   enable_dns_hostnames = true

#   # Manage so we can name
#   manage_default_network_acl    = true
#   default_network_acl_tags      = { Name = "${local.name}-default" }
#   manage_default_route_table    = true
#   default_route_table_tags      = { Name = "${local.name}-default" }
#   manage_default_security_group = true
#   default_security_group_tags   = { Name = "${local.name}-default" }

#   tags = local.tags
# }

# ################################################################################
# # Service discovery namespaces
# ################################################################################

# resource "aws_service_discovery_private_dns_namespace" "this" {
#   name        = "default.${local.name}.local"
#   description = "Service discovery namespace.clustername.local"
#   vpc         = module.vpc.vpc_id

#   tags = local.tags
# }