data "aws_iam_policy_document" "make_website_world_readable" {
  statement {
    sid = "PublicReadGetObject"
    effect = "Allow"
    actions = [ "s3:GetObject" ]
    principals {
      type = "*"
      identifiers = [ "*" ]
    }
    resources = [ "arn:aws:s3:::${local.s3_bucket_name}/*" ]
  }
}

resource "aws_s3_bucket" "blog" {
  bucket = "${local.s3_bucket_name}"
  acl = "public-read"
  policy = "${data.aws_iam_policy_document.make_website_world_readable.json}"
}
