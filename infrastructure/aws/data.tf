data "aws_availability_zones" "available" {}
locals {
  s3_bucket_name = "${var.s3_bucket_name}"
  s3_bucket_origin_id = "${var.s3_bucket_name}"
}
