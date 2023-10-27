locals {
  subnet_ids = { for k, v in aws_subnet.this : v.tags.Name => v.id }

  tags = {
    Project   = "Lanchonete App ECS"
    Service   = "ECS Fargate"
  }
}