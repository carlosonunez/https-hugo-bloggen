resource "aws_cloudfront_origin_access_identity" "blog_access" {
  count = "${var.enable_cloudfront_cdn}"
  comment = "Environment: ${var.environment_name}"
}

resource "aws_cloudfront_distribution" "blog" {
  count = "${var.enable_cloudfront_cdn}"
  tags = "${local.default_tags}"
  aliases = [ "${local.blog_fqdn_requested}" ]
  origin {
    domain_name = "${aws_s3_bucket.blog.website_endpoint}"
    origin_id = "${local.s3_bucket_origin_id}"
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "https_only"
      origin_ssl_protocols = [ "SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2" ]
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  enabled = true
  default_root_object = "${local.index_html_file}"
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
    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }
  custom_error_response {
    error_code = 404
    response_code = 404
    response_page_path = "/${local.error_html_file}"
  }
  price_class = "PriceClass_100"
  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate_validation.aws_managed_https_certificate.certificate_arn}"
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  } 
}
