resource "aws_security_group" "docdb" {
  name = "${var.app_name}-docdb-sg"
  description = "SG for DocumentDB"
  vpc_id      = aws_vpc.vpc.id

  ingress = [{
    cidr_blocks = [ "187.19.185.104/32" ]
    description = "Acesso DocumentDB local"
    from_port = 27017
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    protocol = "tcp"
    security_groups = [aws_security_group.ecs.id]
    self = false
    to_port = 27017
  }]

  egress = [{
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "DocumentDB acesso externo"
    from_port = 0
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    protocol = "-1"
    security_groups = []
    self = false
    to_port = 0
  }] 
}

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "docdb-lanchonete"
  engine                  = "docdb"
  master_username = var.docdb_username
  master_password = var.docdb_password
  preferred_backup_window = "05:00-06:00"
  skip_final_snapshot     = true
  apply_immediately = true
  vpc_security_group_ids = [aws_security_group.docdb.id]
  db_subnet_group_name = aws_db_subnet_group.rds.name
}

resource "aws_docdb_cluster_instance" "docdb_instances" {
  count              = 1
  identifier         = "docdb-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = "db.t3.medium"
  apply_immediately = true
}

resource "aws_docdb_cluster_parameter_group" "docdb_parameter_group" {
  family      = "docdb3.6"
  name        = "example"

  parameter {
    name  = "tls"
    value = "disabled"
  }
}