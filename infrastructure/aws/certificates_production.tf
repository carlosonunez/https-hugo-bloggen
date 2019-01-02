resource "tls_private_key" "lets_encrypt_account_key_production" {
  count = "${var.environment_name == "production" ? 1 : 0}"
  algorithm = "RSA"
}

resource "acme_registration" "lets_encrypt_account_production" {
  count = "${var.environment_name == "production" ? 1 : 0}"
  provider = "acme.production"
  account_key_pem = "${tls_private_key.lets_encrypt_account_key_production.private_key_pem}"
  email_address = "${var.certificate_registration_email_address}"
}

resource "acme_certificate" "https_certificate_production" {
  count = "${var.environment_name == "production" ? 1 : 0}"
  provider = "acme.production"
  account_key_pem = "${acme_registration.lets_encrypt_account_production.account_key_pem}"
  common_name = "${local.blog_fqdn_requested}"
  min_days_remaining = "${var.certificate_validity_period_in_days}"
  dns_challenge {
    provider = "route53"
  }
}
