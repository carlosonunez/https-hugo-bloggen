output "blog_bucket_name" {
  value = "${aws_s3_bucket.blog.id}"
}

output "blog_bucket_url" {
  value = "${aws_s3_bucket.blog.website_endpoint}"
}

output "cdn_url" {
  value = "${element(concat(aws_cloudfront_distribution.blog.*.domain_name, list("none")), 0)}"
}

output "blog_url" {
  value = "${aws_route53_record.blog.fqdn}"
}

output "index_html_name" {
  value = "${local.index_html_file}"
}

output "error_html_name" {
  value = "${local.error_html_file}"
}
