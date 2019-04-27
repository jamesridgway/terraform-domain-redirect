data "aws_route53_zone" "domain" {
  name         = "${var.source_domain}."
}

