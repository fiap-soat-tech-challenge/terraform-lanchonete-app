variable "lanchonete-clients-service" {
  type    = string
  default = "lanchonete-clients-service"
}

variable "lanchonete-order-service" {
  type    = string
  default = "lanchonete-order-service"
}

variable "lanchonete-payment-service" {
  type    = string
  default = "lanchonete-payment-service"
}

variable "lanchonete-production-service" {
  type    = string
  default = "lanchonete-production-service"
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "user_github_actions" {
  type    = string
  default = "github-actions"
}