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

variable "task_name" {
  type    = string
  default = "task-app"
}

variable "container_name" {
  type    = string
  default = "lanchonete-app"
}

variable "container_image" {
  type    = string
  default = "377639963020.dkr.ecr.us-east-2.amazonaws.com/lanchonete-app:latest"
}

variable "container_port" {
  type    = number
  default = 3000
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
}

variable "db_password" {
 type = string
}

variable "db_default_database" {
 type = string
}