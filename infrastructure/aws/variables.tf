variable "environment_name" {
  description = "The name of the environment being provisioned; used in comments and tags."
}

variable "aws_region" {
  description = "The region to use for your AWS resources."
}

variable "aws_access_key" {
  description = "The access key to use."
}

variable "aws_secret_key" {
  description = "The secret key to use."
}

variable "hugo_base_url" {
  description = "The URL that Hugo is hosted from."
}

variable "route53_domain_name" {
  description = "The domain name corresponding to the Route53 hosted zone to use."
}

variable "enable_cloudfront_cdn" {
  description = <<EOF
When enabled, Terraform will deploy a CloudFront distribution to reduce
blog loading times. Disabling this for tests is recommended, as it can take
30 minutes for a distribution to delete itself.
EOF
}

variable "certificate_registration_email_address" {
  description = "Email address to use for the certificate registered on your behalf."
}

variable "certificate_common_name" {
  description = "The common name to apply onto the certificate."
}

variable "certificate_validity_period_in_days" {
  description = "The number of days the certificate provisioned is valid for."
}

variable "blog_version_commit_sha" {
  description = "The blog's commit SHA."
}
