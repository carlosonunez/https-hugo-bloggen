resource "aws_route53_record" "blog" {
  zone_id = "${data.aws_route53_zone.found.zone_id}"
  name = "${local.route53_record_name}"
  type = "CNAME"
  alias {
    name = "${var.enable_cloudfront_cdn == 1 ? aws_cloudfront_distribution.blog.domain_name : aws_s3_bucket.blog.website_domain}"
    zone_id = "${var.enable_cloudfront_cdn == 1 ? aws_cloudfront_distribution.blog.hosted_zone_id : aws_s3_bucket.blog.hosted_zone_id}"
    evaluate_target_health = true
  }
}
