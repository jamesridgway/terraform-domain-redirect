resource "aws_api_gateway_domain_name" "domain" {
  certificate_arn = "${data.aws_acm_certificate.domain.arn}"
  domain_name     = "${var.source_domain}"
}

resource "aws_api_gateway_base_path_mapping" "domain" {
  api_id      = "${aws_api_gateway_rest_api.domain_redirect.id}"
  stage_name  = "${aws_api_gateway_deployment.production.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.domain.domain_name}"
}

resource "aws_route53_record" "domain" {
  name    = "${aws_api_gateway_domain_name.domain.domain_name}"
  type    = "A"
  zone_id = "${data.aws_route53_zone.domain.id}"

  alias {
    evaluate_target_health = true
    name                   = "${aws_api_gateway_domain_name.domain.cloudfront_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.domain.cloudfront_zone_id}"
  }
}

resource "aws_api_gateway_domain_name" "www_domain" {
  certificate_arn = "${data.aws_acm_certificate.domain.arn}"
  domain_name     = "www.${var.source_domain}"
}

resource "aws_api_gateway_base_path_mapping" "www_domain" {
  api_id      = "${aws_api_gateway_rest_api.domain_redirect.id}"
  stage_name  = "${aws_api_gateway_deployment.production.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.www_domain.domain_name}"
}

resource "aws_route53_record" "www_domain" {
  name    = "${aws_api_gateway_domain_name.www_domain.domain_name}"
  type    = "A"
  zone_id = "${data.aws_route53_zone.domain.id}"

  alias {
    evaluate_target_health = true
    name                   = "${aws_api_gateway_domain_name.www_domain.cloudfront_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.www_domain.cloudfront_zone_id}"
  }
}


resource "aws_api_gateway_rest_api" "domain_redirect" {
  name        = "Domain Redirect API: ${var.source_domain}"
  description = "Redirection API for ${var.source_domain}"
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
