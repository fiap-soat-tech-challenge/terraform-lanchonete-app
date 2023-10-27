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

variable "container_name" {
  type    = string
  default = "lanchonete_app"
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
