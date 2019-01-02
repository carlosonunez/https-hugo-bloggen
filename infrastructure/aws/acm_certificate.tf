resource "aws_acm_certificate" "aws_managed_https_certificate_nonprod" {
  count = "${var.environment_name == "production" ? 0 : 1}"
  tags = "${local.default_tags}"
  private_key = "${acme_certificate.https_certificate_nonprod.private_key_pem}"
  certificate_body = "${acme_certificate.https_certificate_nonprod.certificate_pem}"
  certificate_chain = "${acme_certificate.https_certificate_nonprod.issuer_pem}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "aws_managed_https_certificate_production" {
  count = "${var.environment_name == "production" ? 1 : 0}"
  tags = "${local.default_tags}"
  private_key = "${acme_certificate.https_certificate_production.private_key_pem}"
  certificate_body = "${acme_certificate.https_certificate_production.certificate_pem}"
  certificate_chain = "${acme_certificate.https_certificate_production.issuer_pem}"
  lifecycle {
    create_before_destroy = true
  }
}
