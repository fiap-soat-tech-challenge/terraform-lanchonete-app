resource "aws_cloudwatch_log_group" "clients" {
  name              = "/ecs/${var.cluster_name}/${var.task_clients_name}"
  retention_in_days = 3
}

resource "aws_cloudwatch_log_group" "order" {
  name              = "/ecs/${var.cluster_name}/${var.task_order_name}"
  retention_in_days = 3
}

resource "aws_cloudwatch_log_group" "payment" {
  name              = "/ecs/${var.cluster_name}/${var.task_payment_name}"
  retention_in_days = 3
}

resource "aws_cloudwatch_log_group" "producao" {
  name              = "/ecs/${var.cluster_name}/${var.task_production_name}"
  retention_in_days = 3
}

resource "aws_cloudwatch_log_group" "notification" {
  name              = "/ecs/${var.cluster_name}/${var.task_notification_name}"
  retention_in_days = 3
}

resource "aws_cloudwatch_log_group" "mock_payment" {
  name              = "/ecs/${var.cluster_name}/${var.mock_payment_task_name}"
  retention_in_days = 3
}