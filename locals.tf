locals {
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