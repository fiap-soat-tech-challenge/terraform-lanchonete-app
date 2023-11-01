variable "project_name" {
  type    = string
  default = "lanchonete-app"
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "user_github_actions" {
  type    = string
  default = "github-actions"
}

variable "app_task_name" {
  type    = string
  default = "app-task"
}

variable "app_container_name" {
  type    = string
  default = "lanchonete-app"
}

variable "app_container_image" {
  type    = string
  default = "377639963020.dkr.ecr.us-east-2.amazonaws.com/lanchonete-app:latest"
}

variable "app_container_port" {
  type    = number
  default = 3000
}

variable "payment_task_name" {
  type    = string
  default = "payment-task"
}

variable "payment_container_name" {
  type    = string
  default = "payment-lanchonete"
}

variable "payment_container_image" {
  type    = string
  default = "jonilsonds9/mock_pagamento:latest"
}

variable "payment_container_port" {
  type    = number
  default = 3001
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "db_username" {
  type = string
  sensitive = true
}

variable "db_password" {
  type = string
  sensitive = true
}

variable "db_default_database" {
  type = string
}