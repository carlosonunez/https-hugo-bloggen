provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "lets_encrypt_account_key" {
  algorithm = "RSA"
}

resource "acme_registration" "lets_encrypt_account" {
  account_key_pem = "${tls_private_key.lets_encrypt_account_key.private_key_pem}"
  email_address = "${var.certificate_registration_email_address}"
}

resource "acme_certificate" "https_certificate" {
  account_key_pem = "${acme_registration.lets_encrypt_account.account_key_pem}"
  common_name = "${var.certificate_common_name}"
  min_days_remaining = "${var.certificate_validity_period_in_days}"
  dns_challenge {
    provider = "route53"
  }
}

resource "aws_acm_certificate" "aws_managed_https_certificate" {
  private_key = "${acme_registration.lets_encrypt_account.private_key_pem}"
  certificate_body = "${acme_certificate.https_certificate.certificate_pem}"
}
