variable "aws_region" {
  description = "The region to use for your AWS resources."
}

variable "aws_access_key" {
  description = "The access key to use."
}

variable "aws_secret_key" {
  description = "The secret key to use."
}

variable "number_of_azs" {
  description = "The number of availability zones to use."
}

variable "vpc_cidr" {
  description = "The CIDR to assign to the VPC."
}

variable "private_vpc_subnet_cidrs" {
  type = "list"
  description = <<EOF
CIDRs to use for private subnets created within the VPC.
They must be within the CIDR declared by vpc_cidr, and they must equal
the number of AZs requested by 'number_of_azs'
EOF
}

variable "public_vpc_subnet_cidrs" {
  type = "list"
  description = <<EOF
CIDRs to use for public subnets created within the VPC.
They must be within the CIDR declared by vpc_cidr, and they must equal
the number of AZs requested by 'number_of_azs'
EOF
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
