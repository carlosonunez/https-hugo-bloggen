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
  tags = "${local.default_tags}"
  acl = "public-read"
  policy = "${data.aws_iam_policy_document.make_website_world_readable.json}"
  website {
    index_document = "index.html"
    error_document = "404.html"
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
  },
]
EOF
  }
}
