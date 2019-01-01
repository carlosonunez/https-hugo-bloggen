resource "tls_private_key" "lets_encrypt_account_key_nonprod" {
  count = "${var.environment_name == "production" ? 0 : 1}"
  algorithm = "RSA"
}

resource "tls_private_key" "lets_encrypt_account_key_production" {
  count = "${var.environment_name == "production" ? 1 : 0}"
  algorithm = "RSA"
}

resource "acme_registration" "lets_encrypt_account" {
  account_key_pem = "${tls_private_key.lets_encrypt_account_key.private_key_pem}"
  email_address = "${var.certificate_registration_email_address}"
}

resource "acme_certificate" "https_certificate" {
  account_key_pem = "${acme_registration.lets_encrypt_account.account_key_pem}"
  common_name = "${local.blog_fqdn_requested}"
  min_days_remaining = "${var.certificate_validity_period_in_days}"
  dns_challenge {
    provider = "route53"
  }
}

resource "aws_acm_certificate" "aws_managed_https_certificate" {
  tags = "${local.default_tags}"
  private_key = "${acme_certificate.https_certificate.private_key_pem}"
  certificate_body = "${acme_certificate.https_certificate.certificate_pem}"
  certificate_chain = "${acme_certificate.https_certificate.issuer_pem}"
  lifecycle {
    create_before_destroy = true
  }
}
