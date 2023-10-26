terraform {
  required_version = "1.6.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  cloud {
    organization = "fiap_postech"

    workspaces {
      name = "lanchonete-app"
    }
  }
}