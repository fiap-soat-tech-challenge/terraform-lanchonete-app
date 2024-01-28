
resource "aws_security_group" "ecs" {
  name        = "${var.cluster_name}-ecs-task-sg"
  description = "Security Group for ECS Task"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = var.container_port_clients
    to_port         = var.container_port_clients
    security_groups = [aws_security_group.security_group_alb.id]
    cidr_blocks = ["192.168.0.0/16"]
  }

  ingress {
    protocol        = "tcp"
    from_port       = var.mock_payment_container_port
    to_port         = var.mock_payment_container_port
    cidr_blocks = ["192.168.0.0/16"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}