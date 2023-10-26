locals {
  subnet_ids = { for k, v in subnet.this : v.tags.Name => v.id }

  region = "us-east-2"
  name   = "lanchonete-${basename(path.cwd)}"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  container_name = "ecsdemo-frontend"
  container_port = 3000

  tags = {
    Project   = "Lanchonete App ECS"
    Service   = "ECS Fargate"
  }
}