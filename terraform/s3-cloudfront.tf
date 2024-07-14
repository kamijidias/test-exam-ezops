# Define the S3 bucket for the frontend application
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "test-andrew-frontend-bucket"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  versioning {
    enabled = true
  }

  tags = {
    Name = "Frontend Bucket"
  }
}

resource "aws_cloudfront_distribution" "frontend_distribution" {
  origin {
    domain_name = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.frontend_bucket.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend_origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for Vue.js frontend"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.frontend_bucket.id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "Vue.js Frontend Distribution"
  }
}

resource "aws_cloudfront_origin_access_identity" "frontend_origin_access_identity" {
  comment = "Access identity for S3 bucket"
}

