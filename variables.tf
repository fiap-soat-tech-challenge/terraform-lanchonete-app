variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "account_id" {
  type    = string
  default = "377639963020"
}

variable "user_github_actions" {
  type    = string
  default = "github-actions"
}

variable "repository_name" {
  type    = string
  default = "lanchonete_app"
}

variable "container_name" {
  type    = string
  default = "lanchonete_app"
}

variable "container_port" {
  type    = number
  default = 3000
}

variable "memory" {
  type    = string
  default = "512"
}

variable "cpu" {
  type    = string
  default = "256"
}
