provider "aws" {
  region = var.aws_region
}

resource "aws_ecr_repository" "ecr_clients" {
  name = var.lanchonete-clients-service
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "ecr_order" {
  name = var.lanchonete-order-service
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "ecr_payment" {
  name = var.lanchonete-payment-service
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "ecr_production" {
  name = var.lanchonete-production-service
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository_policy" "ecr_policy_clients" {
  repository = aws_ecr_repository.ecr_clients.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "AllowPushPullImage",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}

resource "aws_ecr_repository_policy" "ecr_policy_order" {
  repository = aws_ecr_repository.ecr_order.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "AllowPushPullImage",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}

resource "aws_ecr_repository_policy" "ecr_policy_payment" {
  repository = aws_ecr_repository.ecr_payment.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "AllowPushPullImage",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}

resource "aws_ecr_repository_policy" "ecr_policy_production" {
  repository = aws_ecr_repository.ecr_production.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "AllowPushPullImage",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}

resource "aws_ecr_lifecycle_policy" "lifecycle_clients" {
 repository = aws_ecr_repository.ecr_clients.name
 policy = jsonencode({
   rules = [{
     rulePriority = 1
     description  = "last 5 docker images"
     action = {
       type = "expire"
     }
     selection = {
       tagStatus   = "any"
       countType   = "imageCountMoreThan"
       countNumber = 5
     }
   }]
 })
}

resource "aws_ecr_lifecycle_policy" "lifecycle_order" {
 repository = aws_ecr_repository.ecr_order.name
 policy = jsonencode({
   rules = [{
     rulePriority = 1
     description  = "last 5 docker images"
     action = {
       type = "expire"
     }
     selection = {
       tagStatus   = "any"
       countType   = "imageCountMoreThan"
       countNumber = 5
     }
   }]
 })
}

resource "aws_ecr_lifecycle_policy" "lifecycle_payment" {
 repository = aws_ecr_repository.ecr_payment.name
 policy = jsonencode({
   rules = [{
     rulePriority = 1
     description  = "last 5 docker images"
     action = {
       type = "expire"
     }
     selection = {
       tagStatus   = "any"
       countType   = "imageCountMoreThan"
       countNumber = 5
     }
   }]
 })
}

resource "aws_ecr_lifecycle_policy" "lifecycle_production" {
 repository = aws_ecr_repository.ecr_production.name
 policy = jsonencode({
   rules = [{
     rulePriority = 1
     description  = "last 5 docker images"
     action = {
       type = "expire"
     }
     selection = {
       tagStatus   = "any"
       countType   = "imageCountMoreThan"
       countNumber = 5
     }
   }]
 })
}