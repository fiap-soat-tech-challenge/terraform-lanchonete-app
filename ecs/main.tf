provider "aws" {
  region = var.aws_region
}

resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}"
}

resource "aws_ecs_service" "this" {
  name                = "service-app"
  cluster             = aws_ecs_cluster.this.id
  task_definition     = aws_ecs_task_definition.this.arn
  launch_type         = "FARGATE"
  desired_count       = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  network_configuration {
    subnets          = [aws_subnet.this["pub_a"].id, aws_subnet.this["pub_b"].id]
    security_groups  = [aws_security_group.this.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_task_definition" "this" {
  family = "task-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = var.memory
  cpu                      = var.cpu
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = "jonilsonds9/express-3000:latest"
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
    }
  ])
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "this" {
  name        = "${var.project_name}-ecs-task-sg"
  description = "Security Group for ECS Task"
  vpc_id      = aws_vpc.this.id

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = var.container_port
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}



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