data "aws_acm_certificate" "domain" {
  provider = "aws.use1"
  domain   = "www.${var.source_domain}"
  statuses = ["ISSUED"]
}

