resource "random_string" "bucket_prefix" {
  length = 8
  upper = false
  special = false
}

data "aws_iam_policy_document" "make_website_world_readable" {
  statement {
    sid = "PublicReadGetObject"
    effect = "Allow"
    actions = [ "s3:GetObject" ]
    principals {
      type = "*"
      identifiers = [ "*" ]
    }
    resources = [ "arn:aws:s3:::${random_string.bucket_prefix.result}-${local.s3_bucket_name}/*" ]
  }
}

resource "aws_s3_bucket" "blog" {
  bucket = "${random_string.bucket_prefix.result}-${local.s3_bucket_name}"
  tags = "${local.default_tags}"
  policy = "${data.aws_iam_policy_document.make_website_world_readable.json}"
}

resource "aws_s3_bucket_ownership_controls" "resume_bucket" {
  bucket = aws_s3_bucket.blog.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.blog.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "blog" {
  bucket = aws_s3_bucket.blog.id
  index_document { suffix = "index.html" }
  error_document { key = "404.html" }
  routing_rules = <<EOF
[
  {
    "Condition": {
      "KeyPrefixEquals": "index.html"
    },
    "Redirect": {
      "ReplaceKeyPrefixWith": "${local.index_html_file}"
    }
  },
  {
    "Condition": {
      "KeyPrefixEquals": "404.html"
    },
    "Redirect": {
      "ReplaceKeyPrefixWith": "${local.error_html_file}"
    }
  }
]
EOF
}
