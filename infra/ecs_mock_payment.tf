resource "aws_ecs_task_definition" "mock_payment" {
  family = "mock_payment-task"
  container_definitions = jsonencode([
    {
      name      = var.mock_payment_container_name
      image     = var.mock_payment_container_image
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      portMappings = [
        {
          name = "mock_payment"
          containerPort = var.mock_payment_container_port
          hostPort      = var.mock_payment_container_port
          protocol = "tcp",
          appProtocol = "http"
        }
      ]
      environment = [
        { "name": "LACHONETE_HOST", "value": "payment_service" },
        { "name": "LACHONETE_PORT", "value": "3003" }
      ]
      healthCheck = {
        command: ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:3030/ping || exit 1"],
        startPeriod: 5,
        interval: 10,
        timeout: 5,
        retries: 3,
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.mock_payment.name
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

resource "aws_ecs_service" "mock_payment" {
  name                = "mock_payment-service"
  cluster             = aws_ecs_cluster.this.id
  task_definition     = aws_ecs_task_definition.mock_payment.arn
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  desired_count       = 1
  depends_on = [
    aws_ecs_cluster.this,
    aws_ecs_task_definition.mock_payment,
    aws_ecs_service.payment
  ]
  enable_execute_command = true

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
      port_name      = "mock_payment"
      discovery_name = "mock_payment"
      client_alias {
        dns_name = "mock_payment"
        port     = 3030
      }
    }
  }
}