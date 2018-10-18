data "aws_availability_zones" "available" {}
data "aws_route53_zone" "found" {
  name = "${var.route53_domain_name}."
  private_zone = false
}
locals {
  s3_bucket_name = "${replace(var.hugo_base_url), "^(http|https):\/\/(.*)$", "$2"}"
  s3_bucket_origin_id = "${local.s3_bucket_name}"
  route53_record_name = "${replace(var.hugo_base_url, "^(http|https):\/\/([a-zA-Z0-9-_])\.${var.route53_domain_name}$","$1")}"
}
