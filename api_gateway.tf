resource "aws_api_gateway_domain_name" "domain" {
  certificate_arn = "${data.aws_acm_certificate.domain.arn}"
  domain_name     = "${var.source_domain}"
}

resource "aws_api_gateway_domain_name" "www_domain" {
  certificate_arn = "${data.aws_acm_certificate.domain.arn}"
  domain_name     = "www.${var.source_domain}"
}