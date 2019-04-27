data "aws_route53_zone" "domain" {
  count = "${length(var.source_domains)}"
  name  = "${replace(var.source_domains[count.index], "/^www\\./", "")}."
}

