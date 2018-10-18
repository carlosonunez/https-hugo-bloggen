resource "aws_route53_record" "blog" {
  zone_id = "${data.aws_route53_zone.found.zone_id}"
  name = "${var.hugo_base_url}"
  type = "CNAME"
  alias {
    name = "${aws_cloudfront_distribution.blog.domain_name}"
    zone_id = "${aws_cloudfront_distribution.blog.hosted_zone_id}"
    evaluate_target_health = true
  }
}
