/*==== Global project variables ======*/
variable "environment" {
  type = string
  default = "lanchonete"
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "cluster_name" {
  type    = string
  default = "lanchonete-cluster"
}

variable "app_name" {
  type    = string
  default = "lanchonete-app"
}

variable "user_github_actions" {
  type    = string
  default = "github-actions"
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
  default = ["us-east-2a", "us-east-2b"]
}
/*==== End variables for VPC ======*/


/*==== Clients Service variables ======*/
variable "task_clients_name" {
  type    = string
  default = "clients-task"
}

variable "container_name_clients" {
  type    = string
  default = "clients-service"
}

variable "container_image_clients" {
  type    = string
  default = "377639963020.dkr.ecr.us-east-2.amazonaws.com/lanchonete-clients-service:latest"
}

variable "container_port_clients" {
  type    = number
  default = 3001
}

variable "db_name_clients" {
  type    = string
  default = "clients"
}
/*==== End Clients Service variables ======*/


/*==== Order Service variables ======*/
variable "task_order_name" {
  type    = string
  default = "order-task"
}

variable "container_name_order" {
  type    = string
  default = "order-service"
}

variable "container_image_order" {
  type    = string
  default = "377639963020.dkr.ecr.us-east-2.amazonaws.com/lanchonete-order-service:latest"
}

variable "container_port_order" {
  type    = number
  default = 3002
}

variable "db_name_order" {
  type    = string
  default = "orders"
}
/*==== End Order Service variables ======*/


/*==== Payment Service variables ======*/
variable "task_payment_name" {
  type    = string
  default = "payment-task"
}

variable "container_name_payment" {
  type    = string
  default = "payment-service"
}

variable "container_image_payment" {
  type    = string
  default = "377639963020.dkr.ecr.us-east-2.amazonaws.com/lanchonete-payment-service:latest"
}

variable "container_port_payment" {
  type    = number
  default = 3003
}

variable "db_name_payment" {
  type    = string
  default = "payments"
}
/*==== End Payment Service variables ======*/


/*==== Payment Service variables ======*/
variable "task_production_name" {
  type    = string
  default = "production-task"
}

variable "container_name_production" {
  type    = string
  default = "payment-service"
}

variable "container_image_production" {
  type    = string
  default = "377639963020.dkr.ecr.us-east-2.amazonaws.com/lanchonete-production-service:latest"
}

variable "container_port_production" {
  type    = number
  default = 3004
}

variable "db_name_production" {
  type    = string
  default = "production"
}
/*==== End Payment Service variables ======*/


/*==== mock payment variables ======*/
variable "mock_payment_task_name" {
  type    = string
  default = "mock_payment-task"
}

variable "mock_payment_container_name" {
  type    = string
  default = "mock_payment-app"
}

variable "mock_payment_container_image" {
  type    = string
  default = "jonilsonds9/mock_pagamento:latest"
}

variable "mock_payment_container_port" {
  type    = number
  default = 3030
}
/*==== End mock payment variables ======*/


variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

/*==== RDS variables ======*/
variable "db_rds_username" {
  type = string
  sensitive = true
}

variable "db_rds_password" {
  type = string
  sensitive = true
}
/*==== RDS variables ======*/


/*==== DocumentDB variables ======*/
variable "docdb_username" {
  type = string
  sensitive = true
}

variable "docdb_password" {
  type = string
  sensitive = true
}
/*==== End DocumentDB variables ======*/

variable "iam_policy_arn" {
  type = list
  default = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::377639963020:policy/AllowSSMMessagesECSTasks",
    "arn:aws:iam::377639963020:policy/AllowECSExecuteCommand"
  ]
}