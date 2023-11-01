resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.cluster_name}/${var.app_task_name}"
  retention_in_days = 3
}

resource "aws_cloudwatch_log_group" "payment" {
  name              = "/ecs/${var.cluster_name}/${var.payment_task_name}"
  retention_in_days = 3
}