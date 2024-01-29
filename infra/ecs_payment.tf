resource "aws_ecs_task_definition" "payment" {
  family = "payment-service-task"
  container_definitions = jsonencode([
    {
      name      = var.container_name_payment
      image     = var.container_image_payment
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      portMappings = [
        {
          name = "payment"
          containerPort = var.container_port_payment
          hostPort      = var.container_port_payment
          protocol = "tcp",
          appProtocol = "http"
        }
      ]
      environment = [
        { "name": "NODE_ENV", "value": "production" },
        { "name": "DB_HOST", "value": "${element(split(":", aws_docdb_cluster.docdb.endpoint), 0)}" },
        { "name": "DB_PORT", "value": "27017" },
        { "name": "DB_USER", "value": "${var.docdb_username}" },
        { "name": "DB_PASSWORD", "value": "${var.docdb_password}" },
        { "name": "DB_NAME", "value": "payments" },
        { "name": "DB_SYNCHRONIZE", "value": "true" },
        { "name": "DB_SSL", "value": "true" },
        { "name": "NO_COLOR", "value": "true" },
        { "name": "PAYMENT_URL", "value": "http://mock_payment:3030/pagamento/qrcode" },
        { "name": "PRODUCTION_SERVICE_URL", "value": "http://production_service:3004" },
      ]
      healthCheck = {
        command: ["CMD-SHELL", "curl http://localhost:3003/health || exit 1"],
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
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
}

resource "aws_ecs_service" "payment" {
  name                = "payment-service"
  cluster             = aws_ecs_cluster.this.id
  task_definition     = aws_ecs_task_definition.payment.arn
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  desired_count       = 1
  depends_on = [aws_lb.alb, aws_db_instance.aws_docdb_cluster.docdb]
  enable_execute_command = true

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group_alb.arn
    container_name   = var.container_name_payment
    container_port   = var.container_port_payment
  }

  network_configuration {
    subnets          = aws_subnet.private_subnet.*.id
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
      discovery_name = "payment_service"
      client_alias {
        dns_name = "payment_service"
        port     = 3003
      }
    }
  }
}