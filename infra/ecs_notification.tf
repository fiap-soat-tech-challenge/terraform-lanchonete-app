resource "aws_ecs_task_definition" "notification" {
  family = "notification-service-task"
  container_definitions = jsonencode([
    {
      name      = var.container_name_notification
      image     = var.container_image_notification
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      portMappings = [
        {
          name = "notification"
          containerPort = var.container_port_notification
          hostPort      = var.container_port_notification
          protocol = "tcp",
          appProtocol = "http"
        }
      ]
      environment = [
        { "name": "NODE_ENV", "value": "production" },
        { "name": "QUEUE_HOST", "value": "${aws_mq_broker.rabbitmq.instances.0.endpoints.0}" },
        { "name": "QUEUE_PORT", "value": "5672" },
        { "name": "QUEUE_USER", "value": "${var.rabbitmq_username}" },
        { "name": "QUEUE_PASSWORD", "value": "${var.rabbitmq_password}" },
        { "name": "NO_COLOR", "value": "true" },
      ]
      healthCheck = {
        command: ["CMD-SHELL", "curl http://localhost:3005/health || exit 1"],
        startPeriod: 5,
        interval: 10,
        timeout: 5,
        retries: 3,
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.notification.name
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

resource "aws_ecs_service" "notification" {
  name                = "notification-service"
  cluster             = aws_ecs_cluster.this.id
  task_definition     = aws_ecs_task_definition.notification.arn
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  desired_count       = 1
  depends_on = [
    aws_ecs_cluster.this,
    aws_ecs_task_definition.notification,
    aws_lb.alb,
    aws_mq_broker.rabbitmq
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
      port_name      = "notification"
      discovery_name = "notification_service"
      client_alias {
        dns_name = "notification_service"
        port     = 3005
      }
    }
  }
}