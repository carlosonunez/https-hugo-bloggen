provider "aws" {
  version = "~> 1.54"
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

provider "acme" {
  version = "~> 1.0"
  server_url = "${var.lets_encrypt_acme_server_url}"
}

provider "tls" {
  version = "~> 1.2"
}
