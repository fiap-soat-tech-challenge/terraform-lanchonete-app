resource "aws_mq_broker" "rabbitmq" {
  broker_name = "rabbitmq"
  engine_type        = "RabbitMQ"
  engine_version     = "3.11.20"
  host_instance_type = "mq.t3.micro"
  apply_immediately = true
  publicly_accessible = true

  user {
    username = var.rabbitmq_username
    password = var.rabbitmq_password
  }
}
