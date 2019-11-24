data "archive_file" "redirect" {
  type        = "zip"
  source_dir  = "${path.module}/redirect"
  output_path = "lambda_redirect.zip"
}

resource "aws_lambda_function" "redirect" {
  filename         = data.archive_file.redirect.output_path
  function_name    = "redirect"
  role             = aws_iam_role.redirect_lambda_iam.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.redirect.output_base64sha256
  runtime          = "nodejs8.10"
  publish          = true
  environment {
    variables = {
      DESTINATION_ADDR = var.destination_address
    }
  }
}

resource "aws_lambda_permission" "redirect" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.redirect.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.domain_redirect.id}/*/*"
}
