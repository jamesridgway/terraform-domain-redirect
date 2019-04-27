data "aws_acm_certificate" "domain" {
  provider = "aws.use1"
  domain   = "${var.source_domain}"
  statuses = ["ISSUED"]
}

