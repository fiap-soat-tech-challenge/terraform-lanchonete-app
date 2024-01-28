resource "aws_ecs_task_definition" "clients" {
  family = "clients-task-family"
  container_definitions = jsonencode([
    {
      name      = var.container_name_clients
      image     = var.container_image_clients
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      portMappings = [
        {
          name = "clients"
          containerPort = var.container_port_clients
          hostPort      = var.container_port_clients
          protocol = "tcp",
          appProtocol = "http"
        }
      ]
      environment = [
        { "name": "NODE_ENV", "value": "production" },
        { "name": "DB_HOST", "value": "${element(split(":", aws_db_instance.rds.endpoint), 0)}" },
        { "name": "DB_PORT", "value": "5432" },
        { "name": "DB_USER", "value": "${var.db_rds_username}" },
        { "name": "DB_PASSWORD", "value": "${var.db_rds_password}" },
        { "name": "DB_NAME", "value": "${var.db_rds_default_database}" },
        { "name": "DB_SCHEMA", "value": "public" },
        { "name": "DB_SYNCHRONIZE", "value": "true" },
        { "name": "DB_SSL", "value": "true" },
        { "name": "NO_COLOR", "value": "true" },
      ]
      healthCheck = {
        command: ["CMD-SHELL", "curl http://localhost:3001/health || exit 1"],
        startPeriod: 5,
        interval: 10,
        timeout: 5,
        retries: 3,
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.clients.name
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

resource "aws_ecs_service" "clients" {
  name                = "clients-service"
  cluster             = aws_ecs_cluster.this.id
  task_definition     = aws_ecs_task_definition.clients.arn
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  desired_count       = 1
  depends_on = [aws_lb.alb, aws_db_instance.rds]
  enable_execute_command = true

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group_alb.arn
    container_name   = var.container_name_clients
    container_port   = var.container_port_clients
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
      port_name      = "clients_port"
      discovery_name = "clients_service"
      client_alias {
        dns_name = "clients_service"
        port     = 3001
      }
    }
  }
}