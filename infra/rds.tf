resource "aws_db_subnet_group" "rds" {
  name       = "subnet_group_rds"

  subnet_ids = aws_subnet.private_subnet.*.id

  tags = {
    Name = "DB subnet group"
  }
}

resource "aws_security_group" "rds" {
  name = "${var.app_name}-rds-sg"
  description = "SG for RDS"
  vpc_id      = aws_vpc.vpc.id

  ingress = [{
    cidr_blocks = [ "187.19.185.104/32" ]
    description = "Acesso banco de dado local"
    from_port = 5432
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    protocol = "tcp"
    security_groups = [aws_security_group.ecs.id]
    self = false
    to_port = 5432
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

resource "aws_db_instance" "rds_clients" {
  identifier = "${var.app_name}-rds-clients"
  instance_class = "db.t3.micro"
  allocated_storage = 10
  engine = "postgres"
  engine_version = "15.3"
  username = var.db_rds_username
  password = var.db_rds_password
  db_name = var.db_name_clients
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible = true
  skip_final_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.rds.name
}

resource "aws_db_instance" "rds_order" {
  identifier = "${var.app_name}-rds-order"
  instance_class = "db.t3.micro"
  allocated_storage = 10
  engine = "postgres"
  engine_version = "15.3"
  username = var.db_rds_username
  password = var.db_rds_password
  db_name = var.db_name_order
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible = true
  skip_final_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.rds.name
}

resource "aws_db_instance" "rds_production" {
  identifier = "${var.app_name}-rds-production"
  instance_class = "db.t3.micro"
  allocated_storage = 10
  engine = "postgres"
  engine_version = "15.3"
  username = var.db_rds_username
  password = var.db_rds_password
  db_name = var.db_name_production
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible = true
  skip_final_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.rds.name
}
