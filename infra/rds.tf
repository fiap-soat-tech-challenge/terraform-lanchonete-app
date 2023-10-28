resource "aws_security_group" "rds" {
  name = "${var.project_name}-rds-sg"
  description = "SG for RDS"
  vpc_id      = aws_vpc.this.id

  ingress = [{
    cidr_blocks = [ "187.19.185.70/32" ]
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

resource "aws_db_instance" "rds" {
  identifier = "${var.project_name}-rds"
  allocated_storage = 10
  engine = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.micro"
  username = var.db_username
  password = var.db_password
  db_name = var.db_default_database
  skip_final_snapshot = true
  publicly_accessible = true
  vpc_security_group_ids = [ 
    aws_security_group.rds.id
  ]
}