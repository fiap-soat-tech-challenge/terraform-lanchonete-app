resource "aws_cloudwatch_log_group" "default" {
  name              = "/ecs/${var.project_name}/${var.task_name}"
  retention_in_days = 2
}