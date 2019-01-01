resource "aws_acm_certificate" "aws_managed_https_certificate" {
  tags = "${local.default_tags}"
  private_key = "${var.environment_name == "production" ? acme_certificate.https_certificate_production.private_key_pem : acme_certificate.https_certificate_nonprod_private_key_pem}"
  certificate_body = "${var.environment_name == "production" ? acme_certificate.https_certificate_production.certificate_pem : acme_certificate.https_certificate_nonprod_certificate_pem}"
  certificate_chain = "${var.environment_name == "production" ? acme_certificate.https_certificate_production.issuer_pem : acme_certificate.https_certificate_nonprod_issuer_pem}"
  lifecycle {
    create_before_destroy = true
  }
}
