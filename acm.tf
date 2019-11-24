data "aws_acm_certificate" "domain" {
  count    = length(var.source_domains)
  provider = aws.use1
  domain   = replace(var.source_domains[count.index], "/^www\\./", "")
  statuses = ["ISSUED"]
}

