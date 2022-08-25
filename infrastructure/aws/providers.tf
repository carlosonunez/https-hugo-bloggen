provider "aws" {}

provider "aws" {
  alias = "acm-required-in-us-east-1-for-cloudfront"
  region = "us-east-1"
}
