/*==== Global project variables ======*/
variable "environment" {
  type = string
  default = "lanchonete"
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "app_name" {
  type    = string
  default = "lanchonete-app"
}

variable "cluster_name" {
  type    = string
  default = "lanchonete-cluster"
}
/*==== End global project variables ======*/


/*==== Variables for VPC ======*/
variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/16"
}

variable "public_subnets_cidr" {
  type    = list
  default = ["192.168.0.0/20", "192.168.16.0/20"]
}

variable "private_subnets_cidr" {
  type    = list
  default = ["192.168.128.0/20", "192.168.144.0/20"]
}

variable "availability_zones" {
  type    = list
  default = ["${var.region}a", "${var.region}b"]
}
/*==== End variables for VPC ======*/


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

variable "iam_policy_arn" {
  type = list
  default = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::377639963020:policy/AllowSSMMessagesECSTasks",
    "arn:aws:iam::377639963020:policy/AllowECSExecuteCommand"
  ]
}