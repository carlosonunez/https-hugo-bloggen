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

variable "environment_name" {
  description = "The name of the environment to provision."
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

variable "s3_bucket_name" {
  description = <<EOF
The name to assign to the S3 bucket created for this blog. Ensure that your
bucket name conforms to AWS S3 guidelines, as this will be validated at
apply-time, not plan-time.
See this document for more details: https://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html
NOTE: A random prefix will be added to the name to avoid bucket colocation.
EOF
}

variable "s3_bucket_name_prefix_length" {
  description = "The length of the prefix to assign to the S3 bucket name."
  default = 8
}
