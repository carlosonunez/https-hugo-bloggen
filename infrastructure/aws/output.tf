output "blog_s3_bucket_path" {
  value = "${local.s3_bucket_name}/${aws_s3_bucket.blog.id}"
}

output "bucket_url" {
  value = "${aws_s3_bucket.blog.website_endpoint}"
}

output "cloudfront_url" {
  value = "${aws_s3_bucket.blog.bucket_domain_name}"
}

output "blog_url" {
  value = "${aws_route53_record.blog.fqdn}"
}
