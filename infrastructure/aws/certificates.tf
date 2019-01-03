resource "aws_acm_certificate" "aws_managed_https_certificate" {
  tags = "${local.default_tags}"
  domain_name = "${local.blog_fqdn_requested}"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "aws_managed_https_certificate_validation_record" {
  name    = "${aws_acm_certificate.aws_managed_https_certificate.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.aws_managed_https_certificate.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.found.id}"
  records = ["${aws_acm_certificate.aws_managed_https_certificate.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "aws_managed_https_certificate" {
  certificate_arn         = "${aws_acm_certificate.aws_managed_https_certificate.arn}"
  validation_record_fqdns = ["${aws_route53_record.aws_managed_https_certificate_validation_record.fqdn}"]
}

