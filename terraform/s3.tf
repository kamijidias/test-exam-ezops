resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "test-andrew-frontend-bucket"

  tags = {
    Name = "Test Andrew Frontend Bucket"
  }
}

resource "aws_s3_bucket_website_configuration" "frontend_bucket_website" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_object" "frontend_files" {
  for_each = fileset("path/to/your/frontend/files", "**/*")
  bucket   = aws_s3_bucket.frontend_bucket.bucket
  key      = each.value
  source   = "path/to/your/frontend/files/${each.value}"
  acl      = "public-read"
}