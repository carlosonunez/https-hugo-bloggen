provider "aws" {
  version = "~> 1.54"
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

provider "tls" {
  version = "~> 1.2"
}
