# Creación del bucket de S3 público
resource "aws_s3_bucket" "bucket-publico-jmalarino" {
    bucket = "bucket-publico-jmalarino"
    acl    = "private"
}

# Política de acceso para el bucket privado
resource "aws_s3_bucket_policy" "bucket_publico_policy" {
  bucket = aws_s3_bucket.bucket-publico-jmalarino.id

  policy = jsonencode({
    Version = "2024-04-30",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:*",
        Resource  = [aws_s3_bucket.bucket-publico-jmalarino.arn, aws_s3_bucket.bucket-privado-jmalarino.arn]
        Condition = {
          StringEquals = {
            "aws:SourceVpc" = aws_vpc.jmalarino_vpc.id
          }
        }
      }
    ]
  })
}

# Creación del bucket de S3 privado
resource "aws_s3_bucket" "bucket-privado-jmalarino" {
    bucket = "bucket-privado-jmalarino"
    acl    = "private"
}

# Política de acceso para el bucket privado
resource "aws_s3_bucket_policy" "bucket_privado_policy" {
  bucket = aws_s3_bucket.bucket-privado-jmalarino.id

  policy = jsonencode({
    Version = "2024-04-30",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:*",
        Resource  = [aws_s3_bucket.bucket-privado-jmalarino.arn, aws_s3_bucket.bucket-publico-jmalarino.arn]
        Condition = {
          StringEquals = {
            "aws:SourceVpc" = aws_vpc.jmalarino_vpc.id
          }
        }
      }
    ]
  })
}
