resource "aws_db_subnet_group" "rds" {
  name       = "subnet_group_rds"

  subnet_ids = aws_subnet.private_subnet.*.id

  tags = {
    Name = "DB subnet group"
  }
}
