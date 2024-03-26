resource "aws_ecr_repository" "app_ecr_repo" {
  name         = "${var.project_name}-${var.env}"
  force_delete = true
  tags = {
    Environment = var.env
    Project     = var.project_name
  }
}

resource "aws_ecr_lifecycle_policy" "app_ecr_repo_policy" {
  repository = aws_ecr_repository.app_ecr_repo.name
  policy     = <<EOF
  {
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 10 images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["${var.project_name}"],
                "countType": "imageCountMoreThan",
                "countNumber": 10
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
