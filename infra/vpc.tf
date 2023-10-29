resource "aws_vpc" "this" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.tags, { Name : "${var.project_name}-VPC" })
}

resource "aws_subnet" "us-east-2a" {
  vpc_id            = aws_vpc.this.id
  availability_zone = "us-east-2a"
  cidr_block        = "192.168.1.0/24"

  tags = {
    AZ = "a"
  }
}

resource "aws_subnet" "us-east-2b" {
  vpc_id            = aws_vpc.this.id
  availability_zone = "us-east-2b"
  cidr_block        = "192.168.2.0/24"

  tags = {
    AZ = "b"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge(local.tags, { Name : "${var.project_name}-IGW" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(local.tags, { Name : "${var.project_name}-route-table" })
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.us-east-2a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.us-east-2b.id
  route_table_id = aws_route_table.public.id
}