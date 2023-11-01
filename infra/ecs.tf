resource "aws_ecs_cluster" "this" {
  name = "${var.cluster_name}"
}

resource "aws_ecs_task_definition" "payment" {
  family = "task-payment"
  container_definitions = jsonencode([
    {
      name      = var.payment_container_name
      image     = var.payment_container_image
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      portMappings = [
        {
          name = "payment"
          containerPort = var.payment_container_port
          hostPort      = var.payment_container_port
          protocol = "tcp",
          appProtocol = "http"
        }
      ]
      environment = [
        { "name": "LACHONETE_HOST", "value": "app-lanchonete" },
        { "name": "LACHONETE_PORT", "value": "3000" }
      ]
      healthCheck = {
        command: ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:3001/ping || exit 1"],
        startPeriod: 5,
        interval: 10,
        timeout: 5,
        retries: 3,
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.payment.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.memory
  cpu                      = var.cpu
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn = aws_iam_role.ecsTaskExecutionRole.arn

  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }
}

resource "aws_ecs_task_definition" "app" {
  family = "app-task"
  container_definitions = jsonencode([
    {
      name      = var.app_container_name
      image     = var.app_container_image
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      portMappings = [
        {
          name = "app"
          containerPort = var.app_container_port
          hostPort      = var.app_container_port
          protocol = "tcp",
          appProtocol = "http"
        }
      ]
      environment = [
        { "name": "NODE_ENV", "value": "production" },
        { "name": "DB_HOST", "value": "${element(split(":", aws_db_instance.rds.endpoint), 0)}" },
        { "name": "DB_PORT", "value": "5432" },
        { "name": "DB_USER", "value": "${var.db_username}" },
        { "name": "DB_PASSWORD", "value": "${var.db_password}" },
        { "name": "DB_NAME", "value": "${var.db_default_database}" },
        { "name": "DB_SCHEMA", "value": "public" },
        { "name": "DB_SYNCHRONIZE", "value": "true" },
        { "name": "DB_SSL", "value": "true" },
        { "name": "NO_COLOR", "value": "true" },
        { "name": "PAYMENT_URL", "value": "http://payment-lanchonete:3001/pagamento/qrcode" },
      ]
      healthCheck = {
        command: ["CMD-SHELL", "curl http://localhost:3000/health || exit 1"],
        startPeriod: 5,
        interval: 10,
        timeout: 5,
        retries: 3,
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.memory
  cpu                      = var.cpu
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn = aws_iam_role.ecsTaskExecutionRole.arn

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
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
  count      = "${length(var.iam_policy_arn)}"
  policy_arn = "${var.iam_policy_arn[count.index]}"
}

resource "aws_service_discovery_http_namespace" "this" {
  name        = "internal"
  description = "Descorberta para serviços ECS"
}

resource "aws_ecs_service" "payment" {
  name                = "payment-service"
  cluster             = aws_ecs_cluster.this.id
  task_definition     = aws_ecs_task_definition.payment.arn
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  desired_count       = 1
  enable_execute_command = true

  network_configuration {
    subnets          = [aws_subnet.us-east-2a.id, aws_subnet.us-east-2b.id]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  service_connect_configuration {
    enabled = true
    namespace = aws_service_discovery_http_namespace.this.arn
    service {
      port_name      = "payment"
      discovery_name = "payment-lanchonete"
      client_alias {
        dns_name = "payment-lanchonete"
        port     = 3001
      }
    }
  }
}

resource "aws_ecs_service" "app" {
  name                = "app-service"
  cluster             = aws_ecs_cluster.this.id
  task_definition     = aws_ecs_task_definition.app.arn
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  desired_count       = 1
  depends_on = [aws_lb.this, aws_db_instance.rds, aws_ecs_service.payment]
  enable_execute_command = true

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.app_container_name
    container_port   = var.app_container_port
  }

  network_configuration {
    subnets          = [aws_subnet.us-east-2a.id, aws_subnet.us-east-2b.id]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  service_connect_configuration {
    enabled = true
    namespace = aws_service_discovery_http_namespace.this.arn
    service {
      port_name      = "app"
      discovery_name = "app-lanchonete"
      client_alias {
        dns_name = "app-lanchonete"
        port     = 3000
      }
    }
  }
}

resource "aws_security_group" "ecs" {
  name        = "${var.cluster_name}-ecs-task-sg"
  description = "Security Group for ECS Task"
  vpc_id      = aws_vpc.this.id

  ingress {
    protocol        = "tcp"
    from_port       = var.app_container_port
    to_port         = var.app_container_port
    security_groups = [aws_security_group.alb.id]
    cidr_blocks = ["192.168.0.0/16"]
  }

  ingress {
    protocol        = "tcp"
    from_port       = var.payment_container_port
    to_port         = var.payment_container_port
    cidr_blocks = ["192.168.0.0/16"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}