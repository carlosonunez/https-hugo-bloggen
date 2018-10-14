locals {
  s3_bucket_name = "${random_string.bucket_prefix.result}-${var.s3_bucket_name}"
}

resource "random_string" "bucket_prefix" {
  length = "${var.s3_bucket_name_prefix_length}"
}

data "aws_iam_policy_document" "make_website_world_readable" {
  statement {
    sid = "PublicReadGetObject"
    effect = "Allow"
    actions = [ "s3:GetObject" ]
    resources = [ "arn:aws:s3:::${var.s3_bucket_name}/*" ]
  }
}

resource "aws_s3_bucket" "blog" {
  bucket = "${local.s3_bucket_name}"
  acl = "public-read"
  policy = "${data.aws_iam_policy_document.make_website_world_readable.json}"
}
