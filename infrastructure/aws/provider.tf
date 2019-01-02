provider "aws" {
  version = "~> 1.54"
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

provider "acme" {
  server_url = "https://invalid"
}

provider "acme" {
  alias = "nonprod"
  version = "~> 1.0"
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

provider "acme" {
  alias = "production"
  version = "~> 1.0"
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

provider "tls" {
  version = "~> 1.2"
}
