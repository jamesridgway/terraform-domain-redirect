resource "aws_api_gateway_domain_name" "domain" {
  count = "${length(var.source_domains)}"
  certificate_arn = "${data.aws_acm_certificate.domain.*.arn[count.index]}"
  domain_name     = "${var.source_domains[count.index]}"
}

resource "aws_api_gateway_base_path_mapping" "domain" {
  count = "${length(var.source_domains)}"
  api_id      = "${aws_api_gateway_rest_api.domain_redirect.id}"
  stage_name  = "${aws_api_gateway_deployment.production.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.domain.*.domain_name[count.index]}"
}

resource "aws_route53_record" "domain" {
  count = "${length(var.source_domains)}"
  name    = "${aws_api_gateway_domain_name.domain.*.domain_name[count.index]}"
  type    = "A"
  zone_id = "${data.aws_route53_zone.domain.*.id[count.index]}"

  alias {
    evaluate_target_health = true
    name                   = "${aws_api_gateway_domain_name.domain.*.cloudfront_domain_name[count.index]}"
    zone_id                = "${aws_api_gateway_domain_name.domain.*.cloudfront_zone_id[count.index]}"
  }
}


resource "aws_api_gateway_rest_api" "domain_redirect" {
  name        = "Domain Redirect to: ${var.destination_address}"
  description = "Redirection API for ${var.destination_address}"
}

resource "aws_api_gateway_method" "root_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.domain_redirect.id}"
  resource_id   = "${aws_api_gateway_rest_api.domain_redirect.root_resource_id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "root_method" {
  rest_api_id             = "${aws_api_gateway_rest_api.domain_redirect.id}"
  resource_id             = "${aws_api_gateway_rest_api.domain_redirect.root_resource_id}"
  http_method             = "${aws_api_gateway_method.root_method.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.redirect.arn}/invocations"
}

resource "aws_api_gateway_resource" "path_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.domain_redirect.id}"
  parent_id   = "${aws_api_gateway_rest_api.domain_redirect.root_resource_id}"
  path_part   = "{path+}"
}


resource "aws_api_gateway_method" "path_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.domain_redirect.id}"
  resource_id   = "${aws_api_gateway_resource.path_resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}


resource "aws_api_gateway_integration" "path_method" {
  rest_api_id             = "${aws_api_gateway_rest_api.domain_redirect.id}"
  resource_id             = "${aws_api_gateway_resource.path_resource.id}"
  http_method             = "${aws_api_gateway_method.path_method.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.redirect.arn}/invocations"
}

resource "aws_api_gateway_deployment" "production" {
  depends_on = ["aws_api_gateway_integration.root_method", "aws_api_gateway_integration.path_method"]

  rest_api_id = "${aws_api_gateway_rest_api.domain_redirect.id}"
  stage_name  = "Production"
}
