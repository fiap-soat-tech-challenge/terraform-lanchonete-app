resource "aws_ecr_repository" "this" {
  name = var.repository_name
}

data "aws_iam_policy_document" "ecr_policy" {
  statement {
    sid    = "AllowPushPullImage"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.account_id}:user/${var.user_github_actions}"
      ]
    }

    resources = [
      "arn:aws:ecr:${var.aws_region}:${var.account_id}:repository/${var.repository_name}"
    ]

    actions = [
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
}

resource "aws_ecr_repository_policy" "this" {
  repository = aws_ecr_repository.this.name
  policy = data.aws_iam_policy_document.ecr_policy.json
}

resource "aws_ecr_lifecycle_policy" "this" {
 repository = aws_ecr_repository.this.name
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