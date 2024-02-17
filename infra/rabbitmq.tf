resource "aws_db_subnet_group" "rabbitmq" {
  name       = "subnet_group_rabbitmq"

  subnet_ids = aws_subnet.private_subnet.*.id

  tags = {
    Name = "RabbitMQ subnet group"
  }
}

resource "aws_security_group" "rabbitmq" {
  name = "${var.app_name}-rabbitmq-sg"
  description = "SG for rabbitmq"
  vpc_id      = aws_vpc.vpc.id

  ingress = [{
    cidr_blocks = [ "187.19.185.104/32" ]
    description = "Acesso banco de dado local"
    from_port = 5671
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    protocol = "tcp"
    security_groups = [aws_security_group.ecs.id]
    self = false
    to_port = 5671
  }]

  egress = [{
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "RDS acesso externo"
    from_port = 0
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    protocol = "-1"
    security_groups = []
    self = false
    to_port = 0
  }] 
}

resource "aws_mq_broker" "rabbitmq" {
  broker_name = "rabbitmq"
  engine_type        = "RabbitMQ"
  engine_version     = "3.11.20"
  host_instance_type = "mq.t3.micro"
  apply_immediately = true
  publicly_accessible = true
  security_groups    = [aws_security_group.rabbitmq.id]

  user {
    username = var.rabbitmq_username
    password = var.rabbitmq_password
  }
}
