locals {
  subnet_ids = { for k, v in aws_subnet.this : v.tags.Name => v.id }

  common_tags = {
    Project   = "Lanchonete App ECS"
    CreatedAt = "2023-10-26"
    Service   = "ECS Fargate"
  }
}