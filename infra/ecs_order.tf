resource "aws_ecs_task_definition" "order" {
  family = "order-service-task"
  container_definitions = jsonencode([
    {
      name      = var.container_name_order
      image     = var.container_image_order
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      portMappings = [
        {
          name = "order"
          containerPort = var.container_port_order
          hostPort      = var.container_port_order
          protocol = "tcp",
          appProtocol = "http"
        }
      ]
      environment = [
        { "name": "NODE_ENV", "value": "production" },
        { "name": "DB_HOST", "value": "${element(split(":", aws_db_instance.rds_order.endpoint), 0)}" },
        { "name": "DB_PORT", "value": "5432" },
        { "name": "DB_USER", "value": "${var.db_rds_username}" },
        { "name": "DB_PASSWORD", "value": "${var.db_rds_password}" },
        { "name": "DB_NAME", "value": "${var.db_name_order}" },
        { "name": "DB_SCHEMA", "value": "public" },
        { "name": "DB_SYNCHRONIZE", "value": "true" },
        { "name": "DB_SSL", "value": "true" },
        { "name": "NO_COLOR", "value": "true" },
        { "name": "CLIENTS_SERVICE_URL", "value": "http://clients_service:3001" },
        { "name": "PAYMENTS_SERVICE_URL", "value": "http://mock_payment:3003" },
      ]
      healthCheck = {
        command: ["CMD-SHELL", "curl http://localhost:3002/health || exit 1"],
        startPeriod: 5,
        interval: 10,
        timeout: 5,
        retries: 3,
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.order.name
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

resource "aws_ecs_service" "order" {
  name                = "order-service"
  cluster             = aws_ecs_cluster.this.id
  task_definition     = aws_ecs_task_definition.order.arn
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  desired_count       = 1
  depends_on = [aws_lb.alb, aws_db_instance.rds_order]
  enable_execute_command = true

  load_balancer {
    target_group_arn = aws_lb_target_group.pedidos.arn
    container_name   = var.container_name_order
    container_port   = var.container_port_order
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
      port_name      = "order"
      discovery_name = "order_service"
      client_alias {
        dns_name = "order_service"
        port     = 3002
      }
    }
  }
}