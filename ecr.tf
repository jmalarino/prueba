# Creación del repositorio de Amazon ECR
resource "aws_ecr_repository" "jmalarino_repository" {
  name = "jmalarino-repository"
}

# Política de acceso para el repositorio de ECR
resource "aws_ecr_repository_policy" "jmalarino_repository_policy" {
  repository = aws_ecr_repository.jmalarino_repository.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  })
}