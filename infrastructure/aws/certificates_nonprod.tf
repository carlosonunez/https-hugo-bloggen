resource "tls_private_key" "lets_encrypt_account_key_nonprod" {
  count = "${var.environment_name == "production" ? 0 : 1}"
  algorithm = "RSA"
}

resource "acme_registration" "lets_encrypt_account_nonprod" {
  count = "${var.environment_name == "production" ? 0 : 1}"
  provider = "acme.nonprod"
  account_key_pem = "${tls_private_key.lets_encrypt_account_key_nonprod.private_key_pem}"
  email_address = "${var.certificate_registration_email_address}"
}

resource "acme_certificate" "https_certificate_nonprod" {
  count = "${var.environment_name == "production" ? 0 : 1}"
  provider = "acme.nonprod"
  account_key_pem = "${acme_registration.lets_encrypt_account_nonprod.account_key_pem}"
  common_name = "${local.blog_fqdn_requested}"
  min_days_remaining = "${var.certificate_validity_period_in_days}"
  dns_challenge {
    provider = "route53"
  }
}
