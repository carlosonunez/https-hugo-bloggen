data "aws_route53_zone" "found" {
  name = "${var.route53_domain_name}."
  private_zone = false
}

locals {
  bucket_origin_id = "${var.s3_bucket_origin_id == "" ? replace(var.hugo_base_url, "/^.*:///", "") : var.s3_bucket_origin_id}"
  index_html_file = "index-${var.blog_version_commit_sha}.html"
  error_html_file = "404-${var.blog_version_commit_sha}.html"
  blog_fqdn_requested = "${replace(var.hugo_base_url, "/^.*:///", "")}"
  s3_bucket_name = "${local.blog_fqdn_requested}"
  s3_bucket_origin_id = "${local.bucket_origin_id}"
  route53_record_name = "${replace(local.blog_fqdn_requested, ".${var.route53_domain_name}","")}"
  default_tags = {
    Environment = "${var.environment_name}"
    Version = "${var.blog_version_commit_sha}"
    "Blog URL" = "${var.hugo_base_url}"
  }
}
