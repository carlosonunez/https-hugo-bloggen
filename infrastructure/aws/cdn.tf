resource "aws_cloudfront_origin_access_identity" "blog_access" {
  count = "${var.enable_cloudfront_cdn}"
  comment = "Environment: ${var.environment_name}"
}

resource "aws_cloudfront_distribution" "blog" {
  count = "${var.enable_cloudfront_cdn}"
  tags = "${local.default_tags}"
  origin {
    domain_name =  "${aws_s3_bucket.blog.bucket_regional_domain_name}"
    origin_id = "${local.s3_bucket_origin_id}"
    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.blog_access.cloudfront_access_identity_path}"
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  enabled = true
  default_root_object = "index.html"
  default_cache_behavior {
    allowed_methods = [ "GET","POST","PUT","DELETE","PATCH","OPTIONS","HEAD"]
    cached_methods = [ "GET","HEAD" ]
    target_origin_id = "${local.s3_bucket_origin_id}"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }
  price_class = "PriceClass_100"
  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate.aws_managed_https_certificate.arn}"
    ssl_support_method = "sni-only"
  } 
}
