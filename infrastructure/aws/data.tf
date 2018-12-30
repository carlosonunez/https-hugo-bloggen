data "aws_availability_zones" "available" {}
data "aws_route53_zone" "found" {
  name = "${var.route53_domain_name}."
  private_zone = false
}
locals {
  blog_fqdn_requested = "${replace(var.hugo_base_url, "/^.*:///", "")}"
  s3_bucket_name = "${local.blog_fqdn_requested}"
  s3_bucket_origin_id = "carlos-blog"
  route53_record_name = "${replace(local.blog_fqdn_requested, ".${var.route53_domain_name}","")}"
}
